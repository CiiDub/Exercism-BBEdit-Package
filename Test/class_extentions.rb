module TestFakes
  module Exercism
    # Overides commands for test #download_exercise_with_clipboard
    module FromClipboard
      def display_clipboard_error
        raise StandardError.new, 'Clipboard Error'
      end

      def confirm_and_download( *args )
        args
      end
    end

    # Overides commands for test #download_exercise_with_website
    module FromWebsite
      @test_url = nil
      @test_exercise_choice = nil

      attr_writer :test_url, :test_exercise_choice

      def display_webpage_error
        raise StandardError.new, 'Website Error'
      end

      def check_browsers_for_exercism_url
        @test_url
      end

      def exercise_chooser( exercises )
        [exercises[@test_exercise_choice]]
      end

      def confirm_and_download( *args )
        args
      end
    end
  end
end
