# Module used to download exercisms
module ExercismDownload
	def confirm_and_download( workspace, track_exercise_hash )
		track     = track_exercise_hash['track']
		exercise  = track_exercise_hash['exercise']

		confirmation =
			if exercise_exists?( track, exercise )
				display_overwrite_confirmation( track, exercise )
			else
				display_download_confirmation( track, exercise )
			end

		case confirmation
		when /Download/ then download_exercise( workspace, track, exercise )
		when /Overwrite/ then download_exercise( workspace, track, exercise, force: true )
		when /Open/ then open_downloaded( workspace, track, exercise )
		else exit( 0 )
		end
	end

	def download_exercise( workspace, track, exercise, force: false )
		overwrite = force ? '--force' : ''
		message   = Open3.capture2e( 'exercism', 'download', overwrite, "--track=#{track}", "--exercise=#{exercise}" )[0]
		display_download_error( message ) unless /^Downloaded to/.match? message

		open_downloaded( workspace, track, exercise )
	end

	def open_downloaded( workspace, track, exercise )
		file_path = exercise_filename( workspace, track, exercise )
		system( 'open', '-a', 'BBEdit', file_path )
	end

	def exercise_filename( workspace, track, exercise )
		dir      = File.join( workspace, track, exercise )
		filename =
			Dir
			.children( dir )
			.grep( /#{exercise.gsub( '-', '_' )}\.\w{2,15}/ )
			.first
		File.join( dir, filename )
	end
end
