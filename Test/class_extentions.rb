# Class overides (monkey patches) for use in tests.
module ChangesForTests
  # This allows multible dialogs to be displayed one after the other.
  # As some of the ExercismDialogs exit the program
  module ExercismDialogs
    module NoExit
      def exit( status = 0 )
        status
      end
    end
  end
end
