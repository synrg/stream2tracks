require 'stream2tracks/process'
require 'ostruct'

TEST_CMD=%[for i in $(seq 3); do echo $i; sleep .01; done; echo done]
TEST_VALIDATE=proc{|buf|$out << buf ; /done/.match(buf) ? true : false}
TEST_PROGRESS=proc{|buf|cur=0; buf.scan(/\d+/).each{|i|cur+=i.to_i} ; [cur,6]}
TEST_CURRENT=[1,3,6,6]
TEST_SINGLE=%[1\n2\n3\ndone\n]
TEST_MULTI=%[1\n1\n1\n2\n1\n2\n1\n2\n3\n1\n2\n3\n1\n2\n3\ndone\n1\n2\n3\ndone\n]

describe WatchedProcess do
    describe '#watch' do
	before :each do
	    $out=''
	    @process=WatchedProcess.new TEST_CMD
	end
	it 'should validate output' do
	    options=OpenStruct.new
	    options.validate=TEST_VALIDATE
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
	    options.progress=TEST_PROGRESS
	    eof,status,count,total=nil,nil,0,0
	    while !eof
		status=@process.watch options
		status.current.should == TEST_CURRENT[count]
		count+=1
		eof=status.eof
	    end
	    count.should == 4
	end
    end
end

describe WatchedProcessGroup do
    describe '#watch' do
	before :each do
	    $out=''
	    $stderr=StringIO.new
	    @options=OpenStruct.new
	    @options.validate=TEST_VALIDATE
	    @options.progress=TEST_PROGRESS
	    @processes=WatchedProcessGroup.new
	end
	it 'should run a single process' do
	    @processes << WatchedProcess.new(TEST_CMD)
	    @processes.watch @options
	    $out.should match(TEST_SINGLE)
	end
	it 'should run multiple processes concurrently' do
	    2.times{@processes << WatchedProcess.new(TEST_CMD)}
	    @processes.watch @options
	    $out.should match(TEST_MULTI)
	end
	it 'should display a progress bar' do
	    @processes << WatchedProcess.new(TEST_CMD)
	    @processes.watch @options
	    $stderr.string.should match(/100%/)
	end
    end
end

