require_relative 'exercism_dialogs'
require_relative 'exercism_download'
require_relative 'log_writer'

# Module for integrating BBEdit with the educational website exercism.org and it's CLI tool.
module Exercism
	extend DialogBuilder
	extend ExercismDialogs
	extend ExercismDownload
	extend BBEditLogWriter

	WORKSPACE   = `exercism workspace`.chomp.freeze
	DOC         = ENV['BB_DOC_NAME'].freeze
	CURRENT_DIR = ENV['BB_DOC_PATH'].gsub( DOC, '' ).freeze

	class << self
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
			display_webpage_error if track_exercise_hashes.reject( &:nil? ).empty?

			track_exercise_hash = track_exercise_hashes.length > 1 ? exercise_chooser( track_exercise_hashes )[0] : track_exercise_hashes[0]
			confirm_and_download( WORKSPACE, track_exercise_hash )
		end

		def open_current_exercise
			display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

			system( 'exercism', 'open', CURRENT_DIR )
		end

		def test_current_exercise
			display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

			Dir.chdir CURRENT_DIR do
				message = IO.popen( ['exercism', 'test', { err: [:child, :out] }] ).read
				write_to_log( CURRENT_DIR, DOC, message )
			end
		end

		def submit_current_exercise
			display_outside_workspace_error( DOC, WORKSPACE ) unless workspace?

			Dir.chdir( CURRENT_DIR ) { display_upload_error unless system( 'exercism', 'submit', DOC ) }

			open_current_exercise
		end

		private

		def check_clipboard_for_exercism_command
			IO.popen( ['pbpaste', '-pboard general', { err: [:child, :out] }] ).read
		end

		def check_browsers_for_exercism_url
			Dir.chdir '../../Resources' do
				IO.popen( ['osascript', 'get_ex_url.applescript', { err: [:child, :out] }] ) do | url |
					url.read.chomp.split( "\n" )
				end
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

		def exercise_exists?( track, exercise )
			Dir.exist? File.join( WORKSPACE, track, exercise )
		end
	end
end
