# A module for writing bbedit style logs and errors
module BBEditLogWriter
	# Methods 'write_to_log' and 'ExercismDownload#open_downloaded' use the shell cmd 'open -a app file' rather then the 'bbedit' command.
	# This is because you have to install BBEdits commandline tools explicitly, and some folks (expecially/probably novices) might not.
	def write_to_log( current_dir, doc, message )
		log_dir        = '~/Library/Containers/com.barebones.bbedit/Data/Library/Logs/BBEdit/Unix Script Output'
		log_name       = fun_log_name( current_dir, doc )
		log_path       = File.join( File.expand_path( log_dir ), log_name )
		header_message = make_bbedit_style_output( current_dir, doc, message )
		File.write( log_path, header_message )
		system( 'open', '-a', 'BBEdit', log_path )
	end

	def fun_log_name( current_dir, doc )
		log   = File.basename doc, '.*'
		dir   = File.dirname current_dir
		track = File.basename dir
		"{⏜⏝⏜} #{track} #{log}.log"
	end

	def make_bbedit_style_output( current_dir, doc, message )
		hrz_rule  = ->( char ) { ( 1..80 ).reduce( '' ) { | str, _i | str << char } }
		stamp     = Time.now.strftime '%b %e, %Y at %l:%M:%S %p'
		file_path = File.join( current_dir, doc ).sub( Dir.home, '~' )
		[
			hrz_rule.call( '=' ),
			stamp,
			file_path,
			hrz_rule.call( '-' ),
			message
		].join( "\n" )
	end
end
