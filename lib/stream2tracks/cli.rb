require 'optparse'
require 'ostruct'
require 'stream2tracks/stream_track_ripper'

def stream2tracks argv
    options=OpenStruct.new
    options.format='ogg'
    options.multi=false
    options.debug=false
    options.log=nil

    opts=OptionParser.new do |opts|
	opts.banner = 'Usage: stream2tracks [options] FILENAME|URL'

	opts.on('-d','--debug','Output debugging info.') do
	    options.debug=true
	end

	opts.on('-f','--format FORMAT','Convert tracks to FORMAT (default %s).' % options.format) do |format|
	    options.format=format
	end

	opts.on('-l','--log FILENAME','Log to FILENAME (or - for standard error).') do |filename|
	    options.log=filename
	end

	opts.on('-m','--multi','Download multiple tracks at once (EXPERIMENTAL).') do
	    options.multi=true
	end

	opts.on('-q','--quiet','Suppress output (progress bar).') do
	    options.quiet=true
	end

	opts.on_tail('-h', '--help', 'Show this message.') do
	    puts opts
	    exit
	end

	opts.on_tail('--version', 'Show version.') do
	    puts StreamTrackRipper::Version.join('.')
	    exit
	end
    end
    opts.parse! argv

    unless argv.size == 1
	puts opts
	exit
    end

    input_filename=argv.shift

    StreamTrackRipper.new(ASXStream.new(input_filename),options){}
end
