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

@new_install = false

directory PACKAGE do
	print_dash_header "Fresh install of '#{TITLE}'.", "Restart BBEdit if you don't see the commands in the script menu."

	@new_install = true
end

def make_package_dir_structure( blessed_items )
	blessed_items.each do | item |
		next unless File.directory? item

		mkdir_p File.join( PACKAGE, 'Contents', item ), verbose: false
	end
end

def update_install( files )
	updated_files = []
	files.each do | file |
		install_path = File.join( PACKAGE, 'Contents', file )
		next if uptodate? install_path, [file]

		updated_files << file
		cp file, install_path, verbose: false
	end
	updated_files
end

def remove_orphaned_items( project_items )
	installed_path = File.join( PACKAGE, 'Contents' )
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

def print_updates( updated_files, deleted_files )
	header =
		if updated_files.empty?
			Time.now.strftime( "#{TITLE} is up to date as of: %H:%M:%S - %m/%d/%y" )
		else
			Time.now.strftime( "#{TITLE} installed or updated these files at: %H:%M:%S - %m/%d/%y" )
		end
	print_dash_header( header )
	updated_files.each { | f | puts "✓ - #{f}" }
	deleted_files.each { | f | puts "× - #{f}" }
end

desc "Installs #{TITLE} for use with BBEdit"
task install: PACKAGE do
	blessed_items = FileList.new( '**/*' ).select { | file | blessed? file }
	make_package_dir_structure( blessed_items )
	project_files = blessed_items.reject { | item | File.directory? item }
	updated_files = update_install( project_files )
	deleted_items = remove_orphaned_items( blessed_items )
	exit if @new_install

	print_updates( updated_files, deleted_items )
end

desc "Removes #{TITLE} from BBEdit."
task :uninstall do
	rm_rf PACKAGE, verbose: false
	print_dash_header "'#{TITLE}' was removed from BBEdit"
end
