require 'stream2tracks/process'
require 'ostruct'

describe WatchedProcess do
    describe '#watch' do
	before :each do
	    @process=WatchedProcess.new %[for i in $(seq 3); do echo $i; sleep .01; done; echo done]
	end
	it 'should validate output' do
	    options=OpenStruct.new
	    options.validate=proc{|buf|/done/.match(buf) ? true : false}
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
	    options.progress=proc{|buf|cur=0; buf.scan(/\d+/).each{|i|cur+=i.to_i} ; [cur,6]}
	    eof,status,count,total=nil,nil,0,0
	    progress=[1,3,6,6]
	    while !eof
		status=@process.watch options
		status.current.should == progress[count]
		count+=1
		eof=status.eof
	    end
	    count.should == 4
	end
    end
end

describe WatchedProcessGroup do
    describe '#watch' do
	it 'should run a single process' do
	    pending()
	end
	it 'should run multiple processes concurrently' do
	    pending()
	end
	it 'should display a progress bar' do
	    pending()
	end
    end
end

