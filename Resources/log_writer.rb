# A class for writing bbedit style logs.
# The class can be instantiated with no arguments or with a closure for naming the log file.
# The closure can accept two arguments, a directory name and/or a document name.
class BBEditStyleLogWriter
  LOG_DIR = '~/Library/Containers/com.barebones.bbedit/Data/Library/Logs/BBEdit/Unix Script Output'.freeze
  LOGNAMER = ->( _current_dir, doc ){ "#{doc}.log" }

  def initialize( &log_namer )
  	@log_namer = block_given? ? log_namer : LOGNAMER
  end
  
  def write( current_dir, doc, message )
    log_name       = fun_log_name( current_dir, doc, &@log_namer)
    log_path       = File.join( File.expand_path( LOG_DIR ), log_name )
    header_message = make_bbedit_style_output( current_dir, doc, clean_whitespace( message ))
    File.write log_path, header_message
    system 'open', '-a', 'BBEdit', log_path
  end

  def clean_whitespace( str )
    str
    	.gsub( %r{^(.*?)\r(?!\n)}, '' )
    	.split( "\n" )
    	.map( &:strip )
    	.reject( &:empty? )
    	.join "\n"
  end

  private

	def fun_log_name( current_dir, doc, &custom_namer )
		custom_namer.call(current_dir, doc)
	end

  def make_bbedit_style_output( current_dir, doc, message )
    hrz_rule  = ->( char ) { ( 1..80 ).reduce( '' ) { | str, _i | str << char }}
    stamp     = Time.now.strftime '%b %e, %Y at %l:%M:%S %p'
    file_path = File.join( current_dir, doc ).sub( Dir.home, '~' )
    [
      hrz_rule.call( '=' ),
      stamp,
      file_path,
      hrz_rule.call( '-' ),
      message
    ].join "\n"
  end
end
