require 'json'

# A little class to grave the solutions for an exercise from .exercism/config.json
module Solutions
  extend self

  def list( exercise_dir )
    JSON
      .load_file( File.join( exercise_dir, '.exercism', 'config.json' ))
      .dig( 'files', 'solution' )
  end
end
