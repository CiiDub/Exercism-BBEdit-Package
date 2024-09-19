require 'json'
require_relative 'dialog_builder'

# A module to retrieve the solution -the exercise file or files that hold the solution- from .exercism/config.json for open exercise.
module Solutions
  extend self

  CONFIG_FILE = 'config.json'.freeze

  def choose_if_many( exercise_dir )
    solutions = list exercise_dir
    return solutions if solutions.size == 1

    solution_chooser solutions
  end

  def list( exercise_dir )
    JSON
      .load_file( File.join( exercise_dir, '.exercism', CONFIG_FILE ))
      .dig 'files', 'solution'
  end

  private

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
