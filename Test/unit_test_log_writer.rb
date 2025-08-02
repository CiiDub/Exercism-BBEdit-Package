require 'minitest/autorun'
require 'date'
require_relative '../Resources/log_writer'

describe 'BBEditStyleLogWriter#write' do
  before do
    @doc_path = '/tmp/test.log'
    @log_path = '/tmp/{⏜⏝⏜} track test.log'
    BBEditStyleLogWriter.send( :remove_const, :LOG_DIR )
    BBEditStyleLogWriter::LOG_DIR = '/tmp'.freeze
  end

  after do
    File.delete @log_path
  end

  let( :current_dir ) { 'track/exercise' }
  let( :doc ) { File.basename @doc_path }
  let( :write ) do
    message_body = 'This is a message for test log'
    # returns array with log_path, and log_message
    stub_return = ->( _cmd, _flag, _param, log_path ) { [log_path, File.read( log_path )] }
    BBEditStyleLogWriter.stub( :system, stub_return ) do
      BBEditStyleLogWriter.write( current_dir, doc, message_body )
    end
  end

  it '#write saved to the currect location' do
    log_path, _log_message = write
    expect( log_path ).must_equal @log_path
  end

  it '#write makes the correct message body' do
    _log_path, log_message = write
    expect( log_message.split( "\n" ).last ).must_equal 'This is a message for test log'
  end

  it '#write makes the correct solution file path' do
    _log_path, log_message = write
    expect( log_message.split( "\n" )[2] ).must_equal 'track/exercise/test.log'
  end

  it '#write makes a properly formatted header' do
    _log_path, log_message = write
    log_header = log_message.split( "\n" )[0, 4]
    expect( log_header[0] ).must_match( /={80}/ )
    expect( Date.parse( log_header[1] )).must_be_kind_of Date
    expect( log_header[3] ).must_match( /-{80}/ )
  end
end

describe 'BBEditStyleLogWriter#clean_whitespace' do
  let( :fugly_message_body ) do
    <<~MSG
        This is not a good format.
        	I don't like it.  
      Let us fix it.
    MSG
  end

  let( :nice_message_body ) do
    <<~MSG
      This is not a good format.
      I don't like it.
      Let us fix it.
    MSG
  end

  it 'clean_whitespace makes a nice message body' do
    expect( BBEditStyleLogWriter.clean_whitespace( fugly_message_body )).must_equal nice_message_body.chomp
  end
end

