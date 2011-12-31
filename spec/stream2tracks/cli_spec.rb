require 'stream2tracks/cli'
require 'stringio'
require 'tempfile'

describe 'stream2tracks' do
    before :each do
	$stderr=StringIO.new
	$stdout=StringIO.new
    end
    it 'should require a filename' do
	lambda {stream2tracks ['/dev/null']}.should_not raise_error
	lambda {stream2tracks []}.should raise_error(SystemExit)
	$stdout.string.should match /^Usage:/
    end
    it 'should display help' do
	lambda {stream2tracks ['--help']}.should raise_error(SystemExit)
	$stdout.string.should match /^Usage:/
    end
    it 'should display version' do
	lambda {stream2tracks ['--version','/dev/null']}.should raise_error(SystemExit)
	$stdout.string.should match /^\d+\.\d+\.\d+$/
    end
    it 'should accept format' do
	lambda {stream2tracks ['--format','ogg','/dev/null']}.should_not raise_error
    end
    it 'should accept log' do
	lambda {stream2tracks ['--log','/dev/null','/dev/null']}.should_not raise_error
    end
    it 'should accept quiet' do
	lambda {stream2tracks ['--quiet','/dev/null']}.should_not raise_error
    end
    it 'should accept multi' do
	lambda {stream2tracks ['--multi','/dev/null']}.should_not raise_error
    end
end
