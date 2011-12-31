require 'stream2tracks/asx_stream'
require 'tempfile'

TEST_ALBUM="Some Album"
TEST_ARTIST="Some Person"
TEST_TITLES=[["Title One","file:///file1.wav"],["Title Two","file:///file2.wav"]]

describe ASXStream do
    before :each do
	@stream_file=Tempfile.new ['stream','.asx']
	@stream_file.puts %[<ASX VERSION="3.0">\n<TITLE>%s</TITLE>] % TEST_ALBUM
	TEST_TITLES.each do |params|	
	    @stream_file.puts %[<ENTRY>\n<TITLE>%s</TITLE>\n<REF HREF="%s" />] % params
	    @stream_file.puts %[<AUTHOR>%s</AUTHOR>\n<PARAM NAME="Prebuffer" VALUE="true" />] % TEST_ARTIST
	    @stream_file.puts %[</ENTRY>]
	end
	@stream_file.puts %[</ASX>]
	@stream_file.close
	@stream=ASXStream.new @stream_file.path
    end
    after :each do
	@stream_file.unlink
    end
    describe '#entries' do
	it 'should return entries for an ASX stream' do
	    entries=@stream.entries
	    entries.size.should == 2
	    entries.first.class.should == Nokogiri::XML::Element
	end
    end
    describe '#parse' do
	it 'should return tracks for an ASX stream' do
	    tracks=@stream.parse
	    tracks.size.should == 2
	    tags=tracks.first.tags
	    tags[:title].should == TEST_TITLES.first[0]
	    tags[:artist].should == TEST_ARTIST
	    tags[:album].should == TEST_ALBUM
	    tracks.first.uri.should == TEST_TITLES.first[1]
	end
    end
end

