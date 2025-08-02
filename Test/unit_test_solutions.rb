require 'minitest/autorun'
require 'tempfile'
require 'json'
require_relative '../Resources/solutions'

def config_text( *solutions )
  solution_file_list = solutions.map( &:to_json ).join ', '
  <<~JSON
    {
      "authors": [
        "chris"
      ],
      "contributors": [
        "chris"
      ],
      "files": {
        "solution": [
          #{solution_file_list}
        ],
        "test": [
          "test.rb"
        ],
        "exemplar": [
          "test.rb"
        ]
      },
      "language_versions": "salty",
      "blurb": "test text"
    }
  JSON
end

describe 'Solutions' do
  before do
    FileUtils.mkdir_p '/tmp/.exercism'
    @config = Tempfile.new( ['test_solutions_', '.json'], '/tmp/.exercism' )
    Solutions.send( :remove_const, :CONFIG_FILE )
    Solutions::CONFIG_FILE = File.basename @config.path
  end

  after do
    @config.delete
    FileUtils.rmdir '/tmp/.exercism'
  end

  it '#list with one solutions' do
    @config << config_text( 'solution.rb' )
    @config.rewind
    expect( Solutions.list( '/tmp' )).must_equal ['solution.rb']
  end

  it '#list with two solutions' do
    @config << config_text( 'solution.rb', 'solution1.rb' )
    @config.rewind
    expect( Solutions.list( '/tmp' )).must_equal ['solution.rb', 'solution1.rb']
  end

  it '#choose_if_many with one solution' do
    @config << config_text( 'solution.rb' )
    @config.rewind
    expect( Solutions.choose_if_many( '/tmp' )).must_equal ['solution.rb']
  end

  it '#choose_if_many with two solutions' do
    stub_return = ->( solutions ) { solutions }
    Solutions.stub( :solution_chooser, stub_return ) do
      @config << config_text( 'solution.rb', 'solution1.rb' )
      @config.rewind
      expect( Solutions.choose_if_many( '/tmp' )).must_equal ['solution.rb', 'solution1.rb']
    end
  end
end
