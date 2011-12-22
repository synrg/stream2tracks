require 'digest/md5'
require 'open-uri'

# A Stream is an abstraction of the input audio stream container that has:
# - a path, either a URI or filename
# - a key, uniquely identifying the stream
# - some metadata about the stream (Tags)
# - some entries
#
# Tags are metadata about a stream, its entries or a Track
#
# A Track is separate entry from a stream, containing:
# - some metadata about the track (Tags)
# - a URI
#
# A TrackFile is a file produced from a stream, containing:
# - some metadata about the track (Tags)
# - the filename
# - the format of the file

class Tags < Hash ; end

# TODO: perhaps delegate to tags via method_missing?
class Track < Struct.new :tags,:uri ; end

class TrackFile < Struct.new :tags,:filename,:format ; end

# An abstract class
class Stream
    attr_accessor :tags,:key

    def initialize path
	@path=path
	file=open(@path)
	@raw=file.read
	@tags=Tags.new
    end

    # To be implemented in the concrete subclass
    def entries ; end

    def key
	@key||=Digest::MD5.new.hexdigest(@raw).to_s
    end

    # To be implemented in the concrete subclass
    def parse ; end
end

