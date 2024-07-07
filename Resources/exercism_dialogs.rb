# Added String#mytitlecase for convenience.
class String
	def mytitlecase( delimiter = ' ' )
		split( delimiter ).map( &:capitalize ).join( delimiter )
	end
end

# A helper class to build Applescrit dialog boxes.
module DialogBuilder
	def display_chooser_with( items:, prompt:, default_items: [items[0]], multiselect: false )
		make_list_string = ->( strs ) {
			# Weird Applescript string works, don't touch!.
			strs
				.map { | item | "\"" + item + "\"" } # rubocop:disable Style::StringLiterals
				.join( ', ' )
		}

		items_list = make_list_string.call( items )
		default_items_list = make_list_string.call( default_items )
		multi = multiselect ? ' with multiple selections allowed' : ''
		chooser_script = "set picked to choose from list {#{items_list}} with prompt \"#{prompt}\" default items {#{default_items_list}}#{multi}"
		Open3.capture2e( 'osascript', '-e', chooser_script )[0]
	end

	def display_dialog_with( title:, message:, buttons: [:default], highlighted_button: :default )
		button_string = buttons[0] == :default ? '' : make_button_string( buttons )
		highlighted_button_string = highlighted_button == :default ? '' : " default button #{highlighted_button}"
		dialog_script = "display dialog \"#{message}\" with title \"#{title}\"#{button_string}#{highlighted_button_string}"
		Open3.capture2e( 'osascript', '-e', dialog_script )[0]
	end

	def make_button_string( buttons )
		escaped_button_text = buttons.map { | button | "\"#{button}\"" }
		return escaped_button_text.join( ' ' ).prepend( ' buttons ' ) if buttons.length <= 1

		escaped_button_text.join( ', ' ).prepend( ' buttons {' ) << '}'
	end
end

# Dialog Boxes for use with the Exercism module.
module ExercismDialogs
	def exercise_chooser( exercises )
		exercise_selections = exercises.map do | exercise |
			"Exercise #{exercise['exercise'].gsub( /[-_]/, ' ' ).mytitlecase} in track #{exercise['track'].gsub( /[-_]/, ' ' ).mytitlecase}"
		end

		chosen_exercise = display_chooser_with(
			items: exercise_selections,
			prompt: 'Which Exercise would you like to download?'
		)

		answer_regex = /Exercise (?<exercise>[\w ]+) in track (?<track>[\w ]+)/
		[
			answer_regex
			 .match( chosen_exercise ).named_captures
			 .trasfrom_values { | value | value.downcase.gsub( ' ', '-' ) }
		]
	end

	def display_clipboard_error
		display_dialog_with(
			title: 'Exercism Command Not Found',
			message: '🌎 Open exersism.org\n\n🔎 Find the track and the exercise you want to do.\n\n📋 Click on the copy icon under \"WORK LOCALLY (VIA CLI)\"\n\n☑️️ Then try the command again.',
			buttons: ['OK'],
			highlighted_button: 1
		)
		exit( 0 )
	end

	def display_webpage_error
		display_dialog_with(
			title: 'Exercism Exercise Not Open',
			message: '🌎 Open exersism.org\n\n🔎 Find the track and the exercise you want to do.\n\n☑️️ Then try the command again.',
			buttons: ['OK'],
			highlighted_button: 1
		)
		exit( 0 )
	end

	def display_outside_workspace_error( doc, workspace )
		display_dialog_with(
			title: 'You Are Outside the Exercism Workspace.',
			message: " Sorry, \'#{doc}\' is not an exercise.\n\n Find your exercises in the Exercism workspace:\n\'#{workspace}\'",
			buttons: ['OK'],
			highlighted_button: 1
		)
		exit( 0 )
	end

	def display_download_error( message )
		display_dialog_with(
			title: 'Error Downloading',
			message: message
		)
		exit( 0 )
	end

	def display_download_confirmation( track, exercise )
		display_dialog_with(
			title: 'Confirm Exercism Track and Exercise',
			message: "Download exercise \'#{exercise.gsub( /[-_]/, ' ' ).mytitlecase}\' from track \'#{track.gsub( /[-_]/, ' ' ).mytitlecase}?\'",
			buttons: ['Cancel', 'Download'],
			highlighted_button: 2
		)
	end

	def display_overwrite_confirmation( track, exercise )
		display_dialog_with(
			title: 'Exercism Track and Exercise Exists',
			message: "Exercise \'#{exercise.gsub( /[-_]/, ' ' ).mytitlecase}\' from track \'#{track.gsub( /[-_]/, ' ' ).mytitlecase}\' has been downloaded.",
			buttons: ['Cancel', 'Open', 'Overwrite'],
			highlighted_button: 2
		)
	end

	def display_upload_error
		display_dialog_with(
			title: 'Error Submiting',
			message: 'Your submition did not upload.\n\nDid you try turning it off and on agian?'
		)
		exit( 0 )
	end
end
