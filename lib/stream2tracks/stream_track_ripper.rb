require 'logger'
require 'taglib'
require 'fileutils'
include FileUtils
require 'stream2tracks/asx_stream'
require 'stream2tracks/process'

class StreamTrackRipper
    Version=['0','0','3']

    def initialize stream,options
	@stream=stream
	@options=options
	@log=Logger.new @options.log=='-' ? $stderr : @options.log if @options.log
	@tracks=@stream.parse
	@log.info 'Processing stream: %s' % @stream.key if @log
	@log.info 'Found %i tracks' % @tracks.count if @log
	album=@stream.tags[:album]
	@log.info 'Found stream title: %s' % album if @log and album
	@curdir=Dir.pwd
	@workdir=File.join(ENV['HOME'],'.cache','stream2tracks',@stream.key)
	mkdir_p @workdir
	if block_given?
	    # TODO: support (re)processing selected tracks from any stage
	    trackfiles=get @tracks
	    trackfiles=convert trackfiles,@options.format
	    trackfiles=tag trackfiles
	    @trackfiles=rename trackfiles
	    yield
	end
	# TODO: report on any failures
    end

    TO_BYTES={'GB'=>1000000000,'MB'=>1000000,'KB'=>1000}
    def get tracks
	trackfiles=[]
	processes=WatchedProcessGroup.new
	options=@options.dup
	unless options.quiet
	    options.progress=proc do |buffer|
		current,total=if buffer.scan(/(\d+\.\d+) (.B) \/ (\d+\.\d+) (.B)/m).last
		    cur,cur_unit,tot,tot_unit=$1,$2,$3,$4
		    [(cur.to_f*TO_BYTES[cur_unit.upcase]).to_i,
		     (tot.to_f*TO_BYTES[tot_unit.upcase]).to_i]
		end
		[current,total]
	    end
	    options.validate=proc do |buffer|
		raise 'libmms connection error' if buffer.include? 'libmms error: libmms connection error'
		buffer.include? 'Download complete!'
	    end
	end
	tracks.each do |track|
	    tags=track.tags
	    # TODO: support formats which may not be possible to determine
	    # from the file extension of the entry in the stream (using
	    # magic number from file itself).
	    format=File.extname(File.basename(track.uri)).sub(/^\./,'')
	    @log.info 'Track tags: %s' % tags.inspect if @log
	    output_filename=File.join @workdir,'%02d.%s' % [tags[:track],format]
	    if File.exists? output_filename
		@log.info 'Discarding old partial output: %s' % output_filename if @options.log
		rm output_filename
	    end
	    cmd='mimms "%s" "%s"' % [track.uri,output_filename]
	    @log.info 'Spawning: %s' % cmd if @log
	    processes << WatchedProcess.new(cmd)
	    trackfiles << TrackFile.new(tags,output_filename,format)
	    processes[-1,1].watch options unless @options.multi
	end
	processes.watch options if @options.multi
	trackfiles
    end

    def convert trackfiles,format
	trackfiles.each do |trackfile|
	    tags=trackfile.tags
	    input_filename=trackfile.filename
	    output_filename=File.join @workdir,'%02d.%s' % [tags[:track],format]
	    cmd=case format
	    when 'ogg'
		'ffmpeg -i "%s" -acodec libvorbis "%s"' %
		    [input_filename,output_filename]
	    else # e.g. mp3, flac
		'ffmpeg -i "%s" "%s"' %
		    [input_filename,output_filename]
	    end
	    @log.info 'Spawning: %s' % cmd if @log
	    WatchedProcessGroup.new([WatchedProcess.new(cmd)]).watch(@options)
	    rm input_filename
	    trackfile.filename=output_filename
	    trackfile.format=format
	end
	trackfiles
    end

    def tag trackfiles
	trackfiles.each do |trackfile|
	    @log.info 'Tagging: %s' % trackfile.filename if @log
	    tags=trackfile.tags
	    file=TagLib::File.new trackfile.filename
	    file.album  = tags[:album] if tags[:album]
	    file.title  = tags[:title]
	    file.artist = tags[:artist]
	    file.track  = tags[:track]
	    file.save
	end
	trackfiles
    end

    def rename trackfiles
	trackfiles.each do |trackfile|
	    tags=trackfile.tags
	    input_filename=trackfile.filename
	    output_filename='%02d-%s-%s.%s' %
		[tags[:track],tags[:album] ?
		    tags[:album] :
		    tags[:artist],tags[:title],
		trackfile.format]
	    # Strip characters that could cause problems for some target filesystems
	    output_filename.gsub!(/[:\/\\]/,' ')
	    # And reduce any blanks to underscores as a shell typing aid
	    output_filename.gsub!(/ +/,'_')

	    @log.info 'Renaming: %s to: %s' % [input_filename,output_filename] if @log
	    mv input_filename,output_filename
	    trackfile.filename=output_filename
	end
	trackfiles
    end
end

