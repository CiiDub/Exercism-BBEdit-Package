require 'minitest/autorun'
require 'tempfile'
require_relative '../Resources/package_settings'

def plist_text( tag_name: '', save_on_test: 0, save_on_submit: 0 )
  <<~PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>ExercismSettings</key>
      <dict>
        <key>TagOnTest</key>
        <string>#{tag_name}</string>
        <key>AutoSaveOnTest</key>
        <integer>#{save_on_test}</integer>
        <key>AutoSaveOnSubmit</key>
        <integer>#{save_on_submit}</integer>
      </dict>
    </dict>
    </plist>
  PLIST
end

describe 'Setting' do
  before do
    @plist = Tempfile.new( ['test_settings_', '.plist'], '/tmp' )
    Settings.send :remove_const, :PLIST
    Settings::PLIST = @plist.path
  end

  after do
    @plist.delete
  end

  it '#tag_on_test should return "tag_name"' do
    @plist << plist_text( tag_name: 'tag_name' )
    @plist.rewind
    expect( Settings.tag_on_test ).must_equal 'tag_name'
  end

  it '#tag_on_test should return false' do
    @plist << plist_text
    @plist.rewind
    expect( Settings.tag_on_test ).must_equal false
  end

  it '#autosave_on_test? should return true' do
    @plist << plist_text( save_on_test: '1' )
    @plist.rewind
    expect( Settings.autosave_on_test? ).must_equal true
  end

  it '#autosave_on_test? should return false' do
    @plist << plist_text
    @plist.rewind
    expect( Settings.autosave_on_test? ).must_equal false
  end

  it '#autosave_on_submit? should return true' do
    @plist << plist_text( save_on_submit: '1' )
    @plist.rewind
    expect( Settings.autosave_on_submit? ).must_equal true
  end

  it '#autosave_on_submit? should return false' do
    @plist << plist_text
    @plist.rewind
    expect( Settings.autosave_on_submit? ).must_equal false
  end
end
