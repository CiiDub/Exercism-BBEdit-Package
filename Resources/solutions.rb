require 'json'

# A little class to grave the solutions for an exercise from .exercism/config.json
module Solutions
  extend self

  CONFIG_FILE = 'config.json'.freeze

  def list( exercise_dir )
    JSON
      .load_file( File.join( exercise_dir, '.exercism', CONFIG_FILE ))
      .dig 'files', 'solution'
  end
end
