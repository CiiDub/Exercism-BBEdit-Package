require_relative 'dialog_builder'

# Added String#mytitlecase for convenience.
class String
  def mytitlecase( delimiter = ' ' )
    split( delimiter ).map( &:capitalize ).join( delimiter )
  end
end

# Weird Applescript string stuff. Beware, thar be dragons!
# rubocop:disable Style::StringLiterals

# Dialog Boxes for use with the Exercism module.
module ExercismDialogs
  private

  def exercise_chooser( exercises )
    exercise_selections = exercises.map do | exercise |
      "Exercise #{exercise['exercise'].gsub( /[-_]/, ' ' ).mytitlecase} in track #{exercise['track'].gsub( /[-_]/, ' ' ).mytitlecase}"
    end

    chosen_exercise = DialogBuilder.display_chooser_with(
      items: exercise_selections,
      prompt: 'Which Exercise would you like to download?'
    )
    exit 0 if chosen_exercise.chomp == 'false'

    answer_regex = /Exercise (?<exercise>[\w ]+) in track (?<track>[\w ]+)/
    [
      answer_regex
        .match( chosen_exercise ).named_captures
        .transform_values { | value | value.downcase.gsub( ' ', '-' ) }
    ]
  end

  def display_clipboard_error
    DialogBuilder.display_dialog_with(
      title: 'Exercism Command Not Found',
      message: '🌎 Open exersism.org\n\n🔎 Find the track and the exercise you want to do.\n\n📋 Click on the copy icon under \"WORK LOCALLY (VIA CLI)\"\n\n☑️️ Then try the command again.',
      buttons: ['OK'],
      highlighted_button: 1
    )
    exit 0
  end

  def display_webpage_error
    DialogBuilder.display_dialog_with(
      title: 'Exercism Exercise Not Open',
      message: '🌎 Open exersism.org\n\n🔎 Find the track and the exercise you want to do.\n\n☑️️ Then try the command again.',
      buttons: ['OK'],
      highlighted_button: 1
    )
    exit 0
  end

  def display_outside_workspace_error( doc, workspace )
    DialogBuilder.display_dialog_with(
      title: 'You Are Outside the Exercism Workspace.',
      message: " Sorry, \'#{doc}\' is not an exercise.\n\n Find your exercises in the Exercism workspace:\n\'#{workspace}\'",
      buttons: ['OK'],
      highlighted_button: 1
    )
    exit 0
  end

  def display_download_error( message )
    DialogBuilder.display_dialog_with(
      title: 'Error Downloading',
      message: message
    )
    exit 0
  end

  def display_download_confirmation( track, exercise )
    DialogBuilder.display_dialog_with(
      title: 'Confirm Exercism Track and Exercise',
      message: "Download exercise \'#{exercise.gsub( /[-_]/, ' ' ).mytitlecase}\' from track \'#{track.gsub( /[-_]/, ' ' ).mytitlecase}?\'",
      buttons: ['Cancel', 'Download'],
      highlighted_button: 2
    )
  end

  def display_overwrite_confirmation( track, exercise )
    DialogBuilder.display_dialog_with(
      title: 'Exercism Track and Exercise Exists',
      message: "Exercise \'#{exercise.gsub( /[-_]/, ' ' ).mytitlecase}\' from track \'#{track.gsub( /[-_]/, ' ' ).mytitlecase}\' has been downloaded.",
      buttons: ['Cancel', 'Open', 'Overwrite'],
      highlighted_button: 2
    )
  end

  def display_upload_error( message )
    DialogBuilder.display_dialog_with(
      title: 'Error Submiting',
      message: 'Your submition did not upload.\n\n' + message,
      buttons: ['OK'],
      highlighted_button: 1
    )
    exit 0
  end
end
# rubocop:enable Style::StringLiterals
