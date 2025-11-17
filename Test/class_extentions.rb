module TestFakes
  module Exercism
    # Overides for Settings for tests
    module Settings
      def self.extended( base )
        base.instance_variable_set :@save_on_test, nil
        base.instance_variable_set :@save_on_submit, nil
        base.instance_variable_set :@test_tag, nil
      end

      attr_writer :save_on_test, :save_on_submit, :test_tag

      def autosave_on_test?
        @save_on_test || false
      end

      def autosave_on_submit?
        @save_on_submit || false
      end

      def tag_on_test
        @test_tag || nil
      end
    end

    # Overides for BBEditStyleLogWriter used in testing Exercism methods
    module BBEditStyleLogWriter
      def system( _, _, _, log_path )
        log_path
      end
    end

    # Overides for testing Exercism#download_exercise_with_clipboard
    module FromClipboard
      def display_clipboard_error
        raise StandardError.new, 'Clipboard Error'
      end

      def confirm_and_download( *args )
        args
      end
    end

    # Overides for testing Exercism#download_exercise_with_website
    module FromWebsite
      def self.extended( base )
        base.instance_variable_set :@test_url, nil
        base.instance_variable_set :@test_exercise_choice, nil
      end

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

    # Overides for testing Exercism#open_current_exercise
    module OpenExercise
      def display_outside_workspace_error( *_args )
        raise StandardError.new, 'Outside Workspace Error'
      end

      def call_open( ex_dir )
        ex_dir
      end
    end

    # Overides for testing Exercism#test_current_exercise
    module TestExercise
      def self.extended( base )
        base.instance_variable_set :@fake_status, nil
        base.instance_variable_set :@fake_test_results, nil
        base.instance_variable_set :@saved, nil
      end

      Status = Struct.new( :success? )

      attr_writer :fake_status, :fake_test_results, :saved

      def saved?
        @saved || false
      end

      def display_outside_workspace_error( *_args )
        raise StandardError.new, 'Outside Workspace Error'
      end

      def save_doc
        @saved = true
      end

      def call_test( _ex_dir )
        [@fake_test_results, Status.new( @fake_status )]
      end
    end

    # Overides for testing Exercism#submit_current_exercise
    module SubmitExercise
      def self.extended( base )
        base.instance_variable_set :@fake_status, nil
        base.instance_variable_set :@fake_test_results, nil
        base.instance_variable_set :@saved, nil
      end

      Status = Struct.new( :success? )

      attr_writer :fake_status, :fake_message, :saved

      def saved?
        @saved || false
      end

      def display_outside_workspace_error( *_args )
        raise StandardError.new, 'Outside Workspace Error'
      end

      def display_upload_error( message )
        raise StandardError.new, message
      end

      def save_doc
        @saved = true
      end

      def call_submit( _ex_dir )
        [@fake_message, Status.new( @fake_status )]
      end
    end
  end
end
