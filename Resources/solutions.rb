require 'json'
require_relative 'exercism_dialogs'

# A little class to grave the solutions for an exercise from .exercism/config.json
module Solutions
  extend self

  CONFIG_FILE = 'config.json'.freeze

  def choose_if_many( exercise_dir )
    solutions = list exercise_dir
    return solutions if solutions.size == 1

    solution_chooser solutions
  end

  private

  def list( exercise_dir )
    JSON
      .load_file( File.join( exercise_dir, '.exercism', CONFIG_FILE ))
      .dig 'files', 'solution'
  end

  def solution_chooser( solutions )
    DialogBuilder
      .display_chooser_with(
        items: solutions,
        prompt: 'Choose one or more solutions to submit',
        multiselect: true
      )
      .chomp
      .split ', '
  end
end
