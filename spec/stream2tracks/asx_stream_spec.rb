require 'stream2tracks/asx_stream'
require 'tempfile'

describe ASXStream do
    before :each do
	@album="Some Album"
	@artist="Some Person"
	@titles=[["Title One","file:///file1.wav"],["Title Two","file:///file2.wav"]]

	@stream_file=Tempfile.new ['stream','.asx']
	@stream_file.puts %[<ASX VERSION="3.0">\n<TITLE>%s</TITLE>] % @album
	@titles.each do |params|
	    @stream_file.puts %[<ENTRY>\n<TITLE>%s</TITLE>\n<REF HREF="%s" />] % params
	    @stream_file.puts %[<AUTHOR>%s</AUTHOR>\n<PARAM NAME="Prebuffer" VALUE="true" />] % @artist
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
	    tags[:title].should == @titles.first[0]
	    tags[:artist].should == @artist
	    tags[:album].should == @album
	    tracks.first.uri.should == @titles.first[1]
	end
    end
end

