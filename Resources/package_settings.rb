require 'open3'

# Module for setting optionally behavior in this BBEdit package
module Settings
  extend self

  BUDDY = '/usr/libexec/PlistBuddy'.freeze
  PLIST = Dir.chdir( '../../' ) { File.join Dir.pwd, 'Info.plist' }.freeze

  def tag_on_test
    output, _status = Open3.capture2e BUDDY, '-c', 'print :ExercismSettings:TagOnTest', PLIST
    return false if output.chomp.empty?

    output.chomp
  end

  def autosave_on_test?
    output, _status = Open3.capture2e BUDDY, '-c', 'print :ExercismSettings:AutoSaveOnTest', PLIST
    return false if output.to_i.zero?

    true
  end

  def autosave_on_submit?
    output, _status = Open3.capture2e BUDDY, '-c', 'print :ExercismSettings:AutoSaveOnSubmit', PLIST
    return false if output.to_i.zero?

    true
  end
end
