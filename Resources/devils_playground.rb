# Module to do bad things to String
module StringExtentions
	# Adds a titlecase method to String.
	# Applies Simple rules: 
	# 	1) Always capitalize first word.
	# 	2) Don't capitalize articles, short prepositions or coordinating conjunctions unless rule one applies.
	# 	3) Skip pre-capitalized words.
	module TitleCase
		ARTICLES = %w'a an the'
		PREPOSITIONS = %w'for in on to at by from'
		CONJUNCTIONS = %w'and but or nor for so yet'
		
		refine String do
			def titlecase
				TitleCase.titlecase_with(self)
				.then {TitleCase.titlecase_with( _1, '-' )}
				.then {TitleCase.titlecase_with( _1, '_' )}
				.then {TitleCase.titlecase_with( _1, '.' )}
			end
		end
		
		private
		
		def self.titlecase_with( str, delimiter = ' ' )
			str
			.split( delimiter )
			.map.with_index {|word, index| 
				next word unless TitleCase.capitalize?(word, index)
				
				word.capitalize
			}
			.join( delimiter )
		end
		
		def self.capitalize?( word, index )
			special_words = ARTICLES | PREPOSITIONS | CONJUNCTIONS
			return false if special_words.include?( word ) && index > 0 || /[A-Z]/.match?(word)
			
			true
		end
	end
end
