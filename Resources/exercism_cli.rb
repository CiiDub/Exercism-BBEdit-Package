require 'open3'
require 'shellwords'

# A set of methods that call the Exercism commandline tool directly.
module ExercismCLICalls
  private

  def call_open( dir )
    system 'exercism', 'open', dir
  end

  def call_test( dir )
    Dir.chdir( dir ) { Open3.capture2e 'exercism', 'test' }
  end

  def call_submit( dir )
    Dir.chdir( dir ) do
      Open3.capture2e 'exercism', 'submit', Solutions.choose_if_many( dir ).shelljoin
    end
  end
end
