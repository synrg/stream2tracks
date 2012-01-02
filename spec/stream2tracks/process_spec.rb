require 'stream2tracks/process'
require 'ostruct'

module WatchedProcessSpecHelpers
    def set_params
	@cmd=%[for i in $(seq 3); do echo $i; sleep .1; done; echo done]
	@validate=proc{|buf|$out << buf ; /done/.match(buf) ? true : false}
	@progress=proc{|buf|cur=0; buf.scan(/\d+/).each{|i|cur+=i.to_i} ; [cur,6]}
	@current=[1,3,6,6]
	@single=%[1\n2\n3\ndone\n]
	@multi=%[1\n1\n1\n2\n1\n2\n1\n2\n3\n1\n2\n3\n1\n2\n3\ndone\n1\n2\n3\ndone\n]
    end
end

describe WatchedProcess do
    describe '#watch' do
	include WatchedProcessSpecHelpers
	before :each do
	    set_params
	    $out=''
	    @process=WatchedProcess.new @cmd
	end
	it 'should validate output' do
	    options=OpenStruct.new
	    options.validate=@validate
	    eof,status,count=nil,nil,0
	    while !eof
		status=@process.watch options
		count+=1
		eof=status.eof
	    end
	    count.should == 4
	    status.valid.should == true
	end
	it 'should measure progress' do
	    options=OpenStruct.new
	    options.progress=@progress
	    eof,status,count,total=nil,nil,0,0
	    while !eof
		status=@process.watch options
		status.current.should == @current[count]
		count+=1
		eof=status.eof
	    end
	    count.should == 4
	end
    end
end

describe WatchedProcessGroup do
    describe '#watch' do
	include WatchedProcessSpecHelpers
	before :each do
	    set_params
	    $out=''
	    $stderr=StringIO.new
	    @options=OpenStruct.new
	    @options.validate=@validate
	    @options.progress=@progress
	    @processes=WatchedProcessGroup.new
	end
	it 'should run a single process' do
	    @processes << WatchedProcess.new(@cmd)
	    @processes.watch @options
	    $out.should match(@single)
	end
	it 'should run multiple processes concurrently' do
	    2.times{@processes << WatchedProcess.new(@cmd)}
	    @processes.watch @options
	    $out.should match(@multi)
	end
	it 'should display a progress bar' do
	    @processes << WatchedProcess.new(@cmd)
	    @processes.watch @options
	    $stderr.string.should match(/100%/)
	end
    end
end

