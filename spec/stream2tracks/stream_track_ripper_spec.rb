require 'stream2tracks/stream_track_ripper'
require 'tempfile'
require 'fileutils'
include FileUtils
require 'ostruct'
require 'stringio'
require 'taglib2'

describe StreamTrackRipper do
    before :each do
	@album="Some Album"
	@artist="Some Person"
	@titles=["Title One","Title Two"]

	@wav_files=[]
	2.times do
	    temp_file=Tempfile.new ['test','.wav']
	    temp_file.close
	    @wav_files << temp_file
	    # Generate contents of stream
	    cp File.join(File.dirname(__FILE__),'test.wav'),temp_file.path
	end
        @stream_file=Tempfile.new ['stream','.asx']
        @stream_file.puts %[<ASX VERSION="3.0">\n<TITLE>%s</TITLE>] % @album
	i=0
        @titles.each do |title|
	    # FIXME: use temporary files
            @stream_file.puts %[<ENTRY>\n<TITLE>%s</TITLE>\n<REF HREF="file://%s" />] %
		[title,File.expand_path(@wav_files[i].path)]
            @stream_file.puts %[<AUTHOR>%s</AUTHOR>\n<PARAM NAME="Prebuffer" VALUE="true" />] % @artist
            @stream_file.puts %[</ENTRY>]
	    i+=1
        end
        @stream_file.puts %[</ASX>]
        @stream_file.close
        @stream=ASXStream.new @stream_file.path
	@options=OpenStruct.new
	@options.format='ogg'
	$stderr=StringIO.new
    end

    after :each do
	@wav_files.each{|file|file.unlink} 
        @stream_file.unlink
	@trackfiles=@ripper.instance_variable_get('@trackfiles')
	@trackfiles.each {|trackfile| rm_f trackfile[:filename]} if @trackfiles
    end

    describe '.new' do
	it 'should create a log' do
	    @options.log='-'
	    @ripper=StreamTrackRipper.new(@stream,@options)
	    $stderr.string.should match('INFO -- : Processing stream:')
	    $stderr.string.should match('INFO -- : Found 2 tracks')
	    $stderr.string.should match('INFO -- : Found stream title: Some Album')
	end
	it 'should apply all processing stages when supplied with a block' do
	    @options.log='-'
	    @options.env={'PATH'=>"#{File.dirname(__FILE__)}:/bin:/usr/bin"}
	    @ripper=StreamTrackRipper.new(@stream,@options){}
	    $stderr.string.should match('INFO -- : Found 2 tracks')
	    $stderr.string.should match('INFO -- : Found stream title: Some Album')
	    $stderr.string.should match(/INFO -- : Spawning: mimms.*\/01\.wav/)
	    $stderr.string.should match(/INFO -- : Spawning: mimms.*\/02\.wav/)
	    $stderr.string.should match(/INFO -- : Spawning: ffmpeg.*\/01\.ogg/)
	    $stderr.string.should match(/INFO -- : Spawning: ffmpeg.*\/02\.ogg/)
	    $stderr.string.should match(/INFO -- : Tagging: .*\/01\.ogg/)
	    $stderr.string.should match(/INFO -- : Tagging: .*\/02\.ogg/)
	    $stderr.string.should match(/INFO -- : Renaming: .*01-.*\.ogg/)
	    $stderr.string.should match(/INFO -- : Renaming: .*02-.*\.ogg/)
	end
    end
    describe '#get' do
	it 'should get track files' do
	    @options.env={'PATH'=>"#{File.dirname(__FILE__)}:/bin:/usr/bin"}
	    @ripper=StreamTrackRipper.new(@stream,@options)
	    @ripper.get
	    trackfiles=@ripper.trackfiles
	    trackfiles.count.should == 2
	    trackfiles.each do |trackfile|
		File.exist?(trackfile[:filename]).should be true
		trackfile[:filename].should match /\.wav$/
	    end
	end
    end
    describe '#convert' do
	it 'should convert track files to specified format' do
	    @options.env={'PATH'=>"#{File.dirname(__FILE__)}:/bin:/usr/bin"}
	    @ripper=StreamTrackRipper.new(@stream,@options)
	    @ripper.get
	    @ripper.convert
	    trackfiles=@ripper.trackfiles
	    trackfiles.each{|trackfile| File.exist?(trackfile[:filename]).should be true}
	    trackfiles.count.should == 2
	    trackfiles.each do |trackfile|
		File.exist?(trackfile[:filename]).should be true
		trackfile[:filename].should match /\.ogg$/
	    end
	end
    end
    describe '#tag' do
	it 'should tag files with metadata from stream' do
	    @options.env={'PATH'=>"#{File.dirname(__FILE__)}:/bin:/usr/bin"}
	    @ripper=StreamTrackRipper.new(@stream,@options)
	    @ripper.get
	    @ripper.convert
	    @ripper.tag
	    trackfiles=@ripper.trackfiles
	    trackfiles.each{|trackfile| File.exist?(trackfile[:filename]).should be true}
	    trackfiles.count.should == 2
	    trackfiles.each do |trackfile|
		File.exist?(trackfile[:filename]).should be true
		# TODO: eliminate duplication here
		tags=TagLib::File.new(trackfile[:filename])
		tags.album.should == trackfile[:tags][:album]
		tags.title.should == trackfile[:tags][:title]
		tags.artist.should == trackfile[:tags][:artist]
		tags.track.should == trackfile[:tags][:track]
	    end
	end
    end
    describe '#rename' do
	it 'should rename files based on metadata from stream' do
	    @options.env={'PATH'=>"#{File.dirname(__FILE__)}:/bin:/usr/bin"}
	    @ripper=StreamTrackRipper.new(@stream,@options)
	    @ripper.get
	    @ripper.convert
	    @ripper.rename
	    trackfiles=@ripper.trackfiles
	    trackfiles.each{|trackfile| File.exist?(trackfile[:filename]).should be true}
	    trackfiles.count.should == 2
	    trackfiles.each do |trackfile|
		File.exist?(trackfile[:filename]).should be true
		trackfile[:filename].should match /\d+-#{@album.gsub(' ','_')}-.*\.ogg$/
	    end
	end
    end
end
