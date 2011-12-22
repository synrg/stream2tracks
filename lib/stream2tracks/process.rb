require 'progressbar'

# A WatchedProcessGroup is a group of processes running in parallel,
# all of which can collectively be watched to indicate progress so far.
# It also supports visually representing progress of all processes
# in the group as a progress bar.
class WatchedProcessGroup < Array
    def watch options
	@bar=nil
	update_bar=proc do |current,total|
	    # FIXME: remove hardwired 'Downloading' label
	    @bar=ProgressBar.new('Downloading',total) if total!=@old_total or @bar.nil?
	    @old_total=total
	    @bar.set current
	end

	all_done=false

	until all_done do
	    all_done=true
	    current,@old_total,total=0,0,0
	    each do |_|
		begin
		    status=_.watch options
		rescue RuntimeError => e
		    # FIXME: @log belongs to StreamTrackRipper instance, not WatchedProcessGroup!
		    # TODO: wrap in an error handler to both log and print to stderr
		    @log.error e.message
		    $stderr.puts "\nE: %s: %s" % [@cmd,e.message]
		    delete _
		end
		if status.current
		    # The reported totals may not be accurate. Rather
		    # than recompute the actual total when the track
		    # finishes, just accumulate the reported total
		    # to improve accuracy of the progress bar.
		    current+=status.eof ? status.total : status.current
		    total+=status.total
		end
		all_done=false unless status.eof
	    end
	    update_bar[current,total] if total>0
	end

	@bar.finish if @bar
    end
end

# A WatchedProcess is a process producing output which can be watched
# to indicate progress so far and validate output.
# - It supports these behaviours with the following callbacks:
#    progress[@buffer] => [current,total]
#    validate[@buffer] => true when download is complete and successful
#    - validate may raise if an unrecoverable error occurs before the
#      process is complete
class WatchedProcess
    MAX_READ_LEN=1024 # completely arbitrary
    class Status < Struct.new :eof,:valid,:current,:total ; end

    def initialize cmd
	@out,out_write=IO.pipe
	@cmd=cmd
	@pid=spawn @cmd,:in=>:close,:out=>out_write,:err=>[:child,:out]
	out_write.close
	yield self if block_given?
    end

    def watch options
	progress,validate=options.progress,options.validate
	@buffer||=''
	output=@out.readpartial MAX_READ_LEN rescue EOFError
	@buffer << output if output
	$stderr.print output if options.debug and output
	current,total=progress[@buffer] if progress
	eof=@out.eof?
	valid=validate[@buffer] if validate
	Status.new eof,valid,current,total
    end
end

