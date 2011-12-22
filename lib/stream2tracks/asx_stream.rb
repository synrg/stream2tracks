require 'nokogiri'
require 'stream2tracks/stream'

class ASXStream < Stream
    def entries
	xml.css('ENTRY')
    end

    def parse
	title=xml.css('ASX>TITLE')[0]
	album=title.inner_text if title
	@tags[:album]=album
	count=0
	tracks=[]
	entries.each do |_|
	    tags=@tags.dup
	    count+=1
	    tags.merge!(
		:title=>_.css('TITLE').inner_text,
		:artist=>_.css('AUTHOR').inner_text,
		:track=>count
	    )
	    track=Track.new tags,_.css('REF')[0]['HREF']
	    tracks << track
	end
	tracks
    end

    private

    def xml
	@xml||=Nokogiri::XML(@raw)
    end
end

