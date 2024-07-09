require 'json'

module Solutions
	extend self

	def list( exercise_dir )
		JSON
			.load_file( File.join( exercise_dir, '.exercism', 'config.json' ))
			.fetch( 'files' )
			.fetch( 'solution' )
	end
end
