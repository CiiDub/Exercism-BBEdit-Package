require 'minitest/autorun'
require_relative '../Resources/devils_playground.rb'

describe 'String Extentions' do
	describe 'Title Case' do
		using StringExtentions::TitleCase
			
		it('just spaces') {
			_('pulp fiction'.titlecase).must_equal 'Pulp Fiction'
		}
		
		it('titlecase a silly looking title') {
			_('se7en'.titlecase).must_equal 'Se7en'
		}
		
		it('skip mid-string special words') {
			_('an american werewolf in london'.titlecase).must_equal 'An American Werewolf in London'
		}
		
		it('always capitalize first word') {
			_('a fish called wanda'.titlecase).must_equal 'A Fish Called Wanda'
		}
		
		it('pass on pre-capitalized words') {
			_('E.T. the Extra-Terrestrial'.titlecase).must_equal 'E.T. the Extra-Terrestrial'
		}

		it('titles with periods and hyphans'){
			_('e.t. the extra-terrestrial'.titlecase).must_equal 'E.T. the Extra-Terrestrial'
		}
		
		it('title transformed in two stage chain, acronym upcased, then titlecase') {
			_('la Story'.gsub(/la\b/, 'LA').titlecase).must_equal 'LA Story'
		}
	end
end
