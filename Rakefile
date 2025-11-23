require 'rake/testtask'
require 'open3'
require_relative 'Test/view_dialogs'

TITLE        = 'Exercism BBEdit Package'.freeze
PACKAGE_NAME = "#{TITLE}.bbpackage".freeze
PACKAGE      = File.expand_path "~/Library/Application Support/BBEdit/Packages/#{PACKAGE_NAME}".freeze

# Files and directories supported by BBEdit packages.
BBLESSED_PACKAGE_ITEMS = %w[
  Resources
  Scripts
  Text\ Filters
  Clippings
  Language\ Modules
  Preview\ CSS
  Preview\ Filters
  Preview\ Templates
  Info.plist
].freeze

RELEASE_FORMAT = /v\d\.\d\.\d/.freeze

@new_install = false
@new_release_build = false

directory PACKAGE do
  print_dash_header(
    "Fresh install of '#{TITLE}'.",
    "Restart BBEdit if you don't see the commands in the script menu."
  )

  @new_install = true
end

def make_package_dir_structure( blessed_items, install_dir: PACKAGE )
  updated_dirs = []
  blessed_items.each do | item |
    next unless File.directory? item

    dir = File.join( install_dir, 'Contents', item )
    updated_dirs << item unless Dir.exist? dir
    mkdir_p( dir, verbose: false )
  end
  updated_dirs
end

def update_install( files, install_dir: PACKAGE )
  updated_files = []
  files.each do | file |
    install_path = File.join( install_dir, 'Contents', file )
    next if uptodate? install_path, [file]

    # Only install info.plist once, don't overwrite installed version.
    next if file == 'Info.plist' && File.exist?( install_path )

    updated_files << file
    cp file, install_path, verbose: false
  end
  updated_files
end

def remove_orphaned_items( project_items, install_dir: PACKAGE )
  installed_path = File.join( install_dir, 'Contents' )
  Dir.chdir( installed_path ) do
    installed_items = FileList.new( '**/*' ).reject { | item | project_items.include? item }
    orphaned_files  = installed_items.reject { | item | File.directory? item }
    orphaned_dirs   = installed_items.select { | item | File.directory? item }
    rm( orphaned_files, verbose: false ) + rmdir( orphaned_dirs, verbose: false )
  end
end

def blessed?( file_name )
  BBLESSED_PACKAGE_ITEMS.each do | blessed_item |
    return true if file_name.start_with? blessed_item
  end

  false
end

def print_dash_header( *lines )
  hr_width = lines.max_by( &:length ).length
  header   = lines.join( "\n" )
  h_rule   = hr_width.times.reduce( '' ) { | hr, _ | hr << '-' }
  puts "#{h_rule}\n#{header}\n#{h_rule}"
end

def print_updates( updated_files, deleted_files, update_verb: 'installed' )
  header =
    if updated_files.empty? && deleted_files.empty?
      Time.now.strftime( "#{TITLE} is up to date as of: %H:%M:%S - %m/%d/%y" )
    else
      Time.now.strftime( "#{TITLE} #{update_verb} or updated these files at: %H:%M:%S - %m/%d/%y" )
    end
  print_dash_header( header )
  updated_files.each { | f | puts "✓ - #{f}" }
  deleted_files.each { | f | puts "× - #{f}" }
end

desc "Installs #{TITLE} for use with BBEdit"
task install: PACKAGE do
  blessed_items = FileList.new( '**/*' ).select { | file | blessed? file }
  updated_dirs = make_package_dir_structure( blessed_items )
  project_files = blessed_items.reject { | item | File.directory? item }
  updated_files = update_install( project_files )
  deleted_items = remove_orphaned_items( blessed_items )
  exit if @new_install

  print_updates( updated_files + updated_dirs, deleted_items )
end

desc "Updates changed files in installed #{TITLE}."
task update: :install

desc "Removes #{TITLE} from BBEdit."
task :uninstall do
  rm_rf PACKAGE, verbose: false
  print_dash_header "'#{TITLE}' was removed from BBEdit"
end

desc "Makes or updates '#{PACKAGE_NAME}' in Packages directory."
task :build do | task |
  callers = task.application.top_level_tasks
  output, _error, _status = Open3.capture3( 'git', 'status', '--short' )
  abort( "Commit changes before calling #{callers.first}." ) unless output.empty?

  build_path = File.join( 'Packages', PACKAGE_NAME )
  blessed_items = FileList.new( '**/*' ).select { | file | blessed? file }
  updated_dirs  = make_package_dir_structure( blessed_items, install_dir: build_path )
  project_files = blessed_items.reject { | item | File.directory? item }
  updated_files = update_install( project_files, install_dir: build_path )
  deleted_items = remove_orphaned_items( blessed_items, install_dir: build_path )
  if callers.grep( /^release/ ).empty?
    print_updates(
      updated_files + updated_dirs,
      deleted_items,
      update_verb: 'added to build'
    )
  else
    @new_release_build = !updated_files.empty? || !deleted_items.empty?
  end
end

desc 'Makes a zipped file and commit \'release\' with the latest package build and git tag.'
task :release, [:version] => :build do | _t, args |
  tag = args[:version]
  abort( 'Provide a release version, such as: \'rake release[v0.0.0]\'.' ) if tag.nil?

  abort( 'Provide a release version formatted as so: v0.0.0' ) unless tag.match?( RELEASE_FORMAT )

  zip_name = TITLE.downcase.gsub( ' ', '_' )
  Dir.chdir 'Packages' do
    sh( "zip -q -r '#{zip_name}_#{tag}.zip' '#{PACKAGE_NAME}'", verbose: false ) if @new_release_build
  end
  abort( "No changes have been made for release #{tag}" ) if `git status -s`.empty?

  release_msg = Time.now.strftime( "Release #{tag} created: %H:%M:%S - %m/%d/%y" )
  sh( "git tag -d #{tag} > /dev/null", verbose: false ) if `git tag`.split( "\n" ).include? tag
  sh( "git add Packages/#{zip_name}_#{tag}.zip > /dev/null", verbose: false )
  sh( "git commit -m 'Release #{release_msg}' > /dev/null", verbose: false )
  sh( "git tag #{tag} > /dev/null", verbose: false )
  print_dash_header release_msg
end

namespace 'settings' do
  def set_it( setting, setting_state )
    plist = File.join( PACKAGE, 'Contents', 'Info.plist' )
    buddy = '/usr/libexec/PlistBuddy'
    sh( buddy, '-c', "set :ExercismSettings:#{setting} #{setting_state}", plist, verbose: false )
  end

  desc 'Set option to tag the exercise directory, with the provided tag name, when exercise tests are successful'
  task :tag_on_test, [:tag_name] do | _task, args |
    tag_name = args[:tag_name] == 'off' || args[:tag_name].nil? ? '' : args[:tag_name]
    set_it 'TagOnTest', tag_name
    status = tag_name.empty? ? 'off' : "on and set to '#{tag_name}'"
    print_dash_header "Tag exercise on test is #{status}"
  end

  desc 'Set option to autosave open solution before submiting.'
  task :autosave_on_submit, [:on_off] do | _task, args |
    on_off = String( args[:on_off] ).match?( /true|1|on/ ) ? '1' : 0
    set_it 'AutoSaveOnSubmit', on_off
    status = on_off.to_i.zero? ? 'off' : 'on'
    print_dash_header "Autosave on submit is #{status}."
  end

  desc 'Set option to autosave open solution before testing.'
  task :autosave_on_test, [:on_off] do | _task, args |
    on_off = String( args[:on_off] ).match?( /true|1|on/ ) ? '1' : 0
    set_it 'AutoSaveOnTest', on_off
    status = on_off.to_i.zero? ? 'off' : 'on'
    print_dash_header "Autosave on Test is #{status}."
  end
end

namespace 'tests' do
  desc 'Select and view design of dialog boxes in the package.'
  task :view_dialogs do
    DialogViewer.select
  end

  Rake::TestTask.new( :unit ) do | task |
    task.description = 'Run Unit Tests'
    task.pattern = 'Test/unit_test_*.rb'
  end

  Rake::TestTask.new( :integration ) do | task |
    task.description = 'Run Integration Tests -BBEdit will be brought to front-'
    task.pattern = 'Test/test_*.rb'
  end
end

desc 'Set option to autosave open solution before testing.'
task :tests do
  puts '****** Running Unit Tests ******'
  Rake::Task['tests:unit'].invoke
  puts "\n\n****** Running Integration Tests ******"
  Rake::Task['tests:integration'].invoke
end
