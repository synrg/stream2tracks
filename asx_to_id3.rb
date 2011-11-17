#! /usr/bin/env ruby

require 'nokogiri'
require 'pp'

class Entry < Struct.new(:title,:url,:artist) ; end
input_file=ARGV.shift

doc=Nokogiri::XML(open input_file)
title=doc.css('TITLE')[0].inner_text
entries=doc.css('ENTRY').map do |_|
    Entry.new _.css('TITLE').inner_text,_.css('REF')[0]['HREF'],_.css('AUTHOR').inner_text
end
pp entries
