require_relative '../Resources/exercism_dialogs'
require_relative '../Resources/solutions'
require_relative 'class_extentions'

# Module for viewing dialog boxes
module DialogViewer
  # AccessDialogs is a collection of dialogs
  module AccessDialogs
    extend ExercismDialogs
    extend Solutions
  end

  extend self

  def select
    selection = dialog_chooser
    dialogs = activate_dialogs selection
    dialogs.call unless @multi_select
  end

  private

  def dialog_chooser
    dialogs = %w[
      display_clipboard_error
      display_download_confirmation
      display_download_error
      display_outside_workspace_error
      display_upload_error
      exercise_chooser
      solution_chooser
      All\ Dialogs
    ]

    DialogBuilder
      .display_chooser_with(
        items: dialogs,
        prompt: 'Choose a dialog box to view:',
        multiselect: true
      )
      .chomp
      .to_sym
  end

  def activate_dialogs( choices )
    dialogs = {
      display_clipboard_error: -> { AccessDialogs.send( :display_clipboard_error ) },
      display_download_confirmation: -> { AccessDialogs.send( :display_download_confirmation, 'track', 'exercise' ) },
      display_download_error: -> { AccessDialogs.send( :display_download_error, 'Bad download, bro!' ) },
      display_outside_workspace_error: -> { AccessDialogs.send( :display_outside_workspace_error, 'doc', 'workspace' ) },
      display_overwrite_confirmation: -> { AccessDialogs.send( :display_overwrite_confirmation, 'track', 'exercise' ) },
      display_upload_error: -> { AccessDialogs.send( :display_upload_error, 'No upload, bro!' ) },
      display_webpage_error: -> { AccessDialogs.send( :display_webpage_error ) },
      exercise_chooser: -> { AccessDialogs.send( :exercise_chooser, [{ 'track' => 'one', 'exercise' => 'foo' }, { 'track' => 'one', 'exercise' => 'bar' }] ) },
      solution_chooser: -> { AccessDialogs.send( :solution_chooser, ['one', 'two', 'three'] ) }
    }

    dialogs.default_proc = proc do | dialogs_h, key |
      @multi_select = true
      if key == :'All Dialogs'
        dialogs_h.each_value do | dialog |
          dialog.call
        rescue SystemExit
          next
        end
        return
      end

      multi_select = key.to_s.gsub( ', ', ' ' ).sub( 'All Dialogs', '' ).strip.split.map( &:to_sym )
      multi_select.each do | selection |
        dialogs_h[selection].call
      rescue SystemExit
        next
      end
    end

    dialogs[choices]
  end
end
