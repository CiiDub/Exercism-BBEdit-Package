module StringExtentions
	module TitleCase
		refine String do
			def titlecase( delimiter = ' ' )
				split( delimiter ).map( &:capitalize ).join( delimiter )
			end
		end
	end
end
