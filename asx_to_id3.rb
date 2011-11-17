#! /usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'tmpdir'
require 'pp'

class Entry < Struct.new(:title,:url,:artist,:track) ; end
input_file=ARGV.shift
tmpdir=Dir.mktmpdir('asx2mp3')

doc=Nokogiri::XML(open input_file)
title=doc.css('TITLE')[0].inner_text
count=0
doc.css('ENTRY').each do |_|
    count+=1
    entry=Entry.new _.css('TITLE').inner_text,_.css('REF')[0]['HREF'],_.css('AUTHOR').inner_text,count
    puts "Processing: "
    pp entry
    infile=File.join(tmpdir,'%02d.wmv' % [count])
    outfile=File.join(tmpdir,'%02d.mp3' % [count])
    system('mplayer -dumpstream -dumpfile %s %s' % [infile,entry.url])
    system('ffmpeg -i %s %s' % [infile,outfile])
    system('id3v2 "%s" -T %i -t "%s" -a "%s"' % [outfile,entry.track,entry.title,entry.artist])
end
