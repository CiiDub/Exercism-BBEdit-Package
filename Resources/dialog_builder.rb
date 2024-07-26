require 'open3'

# A helper class to build Applescrit dialog boxes.
module DialogBuilder
  extend self

  def display_chooser_with( items:, prompt:, default_items: [items[0]], multiselect: false )
    make_list_string = ->( strs ) {
      strs
        .map { | item | "\"" + item + "\"" }
        .join ', '
    }

    items_list = make_list_string.call( items )
    default_items_list = make_list_string.call( default_items )
    multi = multiselect ? ' with multiple selections allowed' : ''
    chooser_script = "set picked to choose from list {#{items_list}} with prompt \"#{prompt}\" default items {#{default_items_list}}#{multi}"
    Open3.capture2e( 'osascript', '-e', chooser_script ).first
  end

  def display_dialog_with( title:, message:, buttons: [:default], highlighted_button: :default )
    button_string = buttons.first == :default ? '' : make_button_string( buttons )
    highlighted_button_string = highlighted_button == :default ? '' : " default button #{highlighted_button}"
    dialog_script = "display dialog \"#{message}\" with title \"#{title}\"#{button_string}#{highlighted_button_string}"
    Open3.capture2e( 'osascript', '-e', dialog_script ).first
  end

  def make_button_string( buttons )
    escaped_button_text = buttons.map { | button | "\"#{button}\"" }
    return escaped_button_text.join( ' ' ).prepend( ' buttons ' ) if buttons.length <= 1

    escaped_button_text.join( ', ' ).prepend( ' buttons {' ) << '}'
  end
end
