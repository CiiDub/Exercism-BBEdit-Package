require 'open3'
require 'shellwords'
require_relative 'exercism_dialogs'
require_relative 'exercism_download'
require_relative 'exercism_workspace'
require_relative 'log_writer'
require_relative 'solutions'
require_relative 'package_settings'

# NOTE: Methods "BBEditStyleLogWriter.write" and "ExercismDownload#open_downloaded" use the shell cmd "open -a <app> <file>" rather then the "bbedit <file>" command.
# This is because you have to install BBEdits commandline tools explicitly, and some folks (expecially/probably novices) might not.

# Module for integrating BBEdit with the educational website exercism.org and it's commandline tool.
module Exercism
  extend self
  extend ExercismWorkspaceAndExercises
  extend ExercismDialogs
  extend ExercismDownload

  WORKSPACE    = `exercism workspace`.chomp.freeze
  DOC          = ENV['BB_DOC_NAME'].freeze
  CURRENT_DIR  = ENV['BB_DOC_PATH'].gsub( DOC, '' ).freeze

  def download_exercise_with_clipboard
    clipboard_regex_pattern = /exercism download --track=(?<track>[\w-]+) --exercise=(?<exercise>[\w-]+)/
    clipboard               = check_clipboard_for_exercism_command
    track_exercise_hash     = make_track_exercise_hash( clipboard, clipboard_regex_pattern )[0]
    display_clipboard_error if track_exercise_hash.nil?

    confirm_and_download WORKSPACE, track_exercise_hash
  end

  def download_exercise_with_website
    download_regex_pattern = %r{https://exercism.org/tracks/(?<track>[\w-]+)/exercises/(?<exercise>[\w-]+)}
    urls                   = check_browsers_for_exercism_url
    track_exercise_hashes  = make_track_exercise_hash urls, download_regex_pattern
    display_webpage_error if track_exercise_hashes.compact.empty?

    track_exercise_hash = track_exercise_hashes.empty? ? exercise_chooser( track_exercise_hashes )[0] : track_exercise_hashes[0]
    confirm_and_download WORKSPACE, track_exercise_hash
  end

  def open_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    system 'exercism', 'open', exercism_dir( CURRENT_DIR )
  end

  def test_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    dir = exercism_dir CURRENT_DIR
    save_doc if Settings.autosave_on_test?
    message, status = Dir.chdir( dir ) { Open3.capture2e 'exercism', 'test' }
    tag_name = Settings.tag_on_test
    tag_exercise( status.success?, tag_name, dir ) if tag_name
    BBEditStyleLogWriter.write dir, Solutions.list( dir ).first, message
  end

  def submit_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    dir = exercism_dir CURRENT_DIR
    solutions = -> {
      solution = Solutions.list dir
      return solution if solution.size == 1

      solution_chooser solutions
    }
    save_doc if Settings.autosave_on_submit?
    message, status =
      Dir.chdir( dir ) do
        Open3.capture2e 'exercism', 'submit', solutions.call.shelljoin
      end
    display_upload_error( BBEditStyleLogWriter.clean_whitespace( message )) unless status.success?

    BBEditStyleLogWriter.write dir, DOC, message
    open_current_exercise
  end
end
