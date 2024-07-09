require 'open3'
require 'shellwords'
require_relative 'exercism_dialogs'
require_relative 'exercism_download'
require_relative 'log_writer'
require_relative 'solutions'

# Methods ' BBEditStyleLogWriter.write' and 'ExercismDownload#open_downloaded' use the shell cmd 'open -a app file' rather then the 'bbedit' command.
# This is because you have to install BBEdits commandline tools explicitly, and some folks (expecially/probably novices) might not.

# Module for integrating BBEdit with the educational website exercism.org and it's CLI tool.
module Exercism
  extend self

  WORKSPACE    = `exercism workspace`.chomp.freeze
  DOC          = ENV['BB_DOC_NAME'].freeze
  CURRENT_DIR  = ENV['BB_DOC_PATH'].gsub( DOC, '' ).freeze

  def download_exercise_with_clipboard
    clipboard_regex_pattern = /exercism download --track=(?<track>[\w-]+) --exercise=(?<exercise>[\w-]+)/
    clipboard               = check_clipboard_for_exercism_command
    track_exercise_hash     = make_track_exercise_hash( clipboard, clipboard_regex_pattern )[0]
    display_clipboard_error if track_exercise_hash.nil?

    confirm_and_download( WORKSPACE, track_exercise_hash )
  end

  def download_exercise_with_website
    download_regex_pattern = %r{https://exercism.org/tracks/(?<track>[\w-]+)/exercises/(?<exercise>[\w-]+)}
    urls                   = check_browsers_for_exercism_url
    track_exercise_hashes  = make_track_exercise_hash( urls, download_regex_pattern )
    display_webpage_error if track_exercise_hashes.compact.empty?

    track_exercise_hash = track_exercise_hashes.empty? ? exercise_chooser( track_exercise_hashes )[0] : track_exercise_hashes[0]
    confirm_and_download( WORKSPACE, track_exercise_hash )
  end

  def open_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    system( 'exercism', 'open', exercism_dir( CURRENT_DIR )  )
  end

  def test_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    dir = exercism_dir( CURRENT_DIR )
    Dir.chdir dir do
      message = Open3.capture2e( 'exercism', 'test' )[0]
      BBEditStyleLogWriter.write( dir, DOC, message )
    end
  end

  def submit_current_exercise
    display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

    dir = exercism_dir( CURRENT_DIR )
    Dir.chdir dir do
      solutions = -> {
        solution = Solutions.list dir
        return solution if solution.size == 1

        solution_chooser( solutions )
      }
      message, status = Open3.capture2e( 'exercism', 'submit', solutions.call.shelljoin )
      display_upload_error unless status.success?

      BBEditStyleLogWriter.write( dir, DOC, message )
      open_current_exercise
    end
  end

  private

  extend DialogBuilder
  extend ExercismDialogs
  extend ExercismDownload

  def check_clipboard_for_exercism_command
    Open3.capture2e( 'pbpaste', '-pboard general' )[0]
  end

  def check_browsers_for_exercism_url
    Dir.chdir '../../Resources' do
      Open3.capture2( 'osascript', 'get_ex_url.applescript' )[0].chomp.split( "\n" )
    end
  end

  def make_track_exercise_hash( *strs, regex )
    strs
      .flatten
      .uniq
      .map do | str |
        match = regex.match( str )
        next match if match.nil?

        match.named_captures
      end
  end

  def workspace?
    CURRENT_DIR.start_with? WORKSPACE
  end

  def exercism_dir( cur_dir, search_iterations = 5 )
    previous_dir = Dir.pwd
    Dir.chdir cur_dir
    dir_search_result =
      loop.with_index( 1 ) do | _, parent_dirs_searched |
        break :out_of_workspace unless workspace?

        break Dir.pwd if Dir.children( Dir.pwd ).include? '.exercism'

        break :out_of_workspace if parent_dirs_searched >= search_iterations

        Dir.chdir '..'
      end
    Dir.chdir previous_dir
    display_outside_workspace_error( DOC, WORKSPACE ) if dir_search_result == :out_of_workspace

    dir_search_result
  end

  def exercise_exists?( track, exercise )
    Dir.exist? File.join( WORKSPACE, track, exercise )
  end
end
