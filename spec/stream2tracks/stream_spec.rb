require 'stream2tracks/stream'
require 'tempfile'

describe 'Stream' do
    describe '#key' do
	it 'should make an MD5 digest from raw contents' do
	    stream_file=Tempfile.new ['test_stream','.asx']
	    begin
		stream_file.puts 'abcd'
		stream_file.close
		Stream.new(stream_file.path).key.should == 'f5ac8127b3b6b85cdc13f237c6005d80'
	    ensure
		stream_file.close
		stream_file.unlink
	    end
	end
    end
end
