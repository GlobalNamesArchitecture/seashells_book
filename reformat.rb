#!/usr/bin/env ruby

class Reader
  attr_reader :file
  def initialize
    @filename = "americanseashell1-corrected.txt"
    @file = open(File.join(File.dirname(__FILE__), 'resources', @filename)).readlines
    @pages = @file.enum_for(:each_slice, 60).to_a
    @offsets = []
    @cursor = 0
    @start_tag = "<tname>"
    @end_tag = "</tname>"
    @between_tags = false
  end

  def find_offsets
    count = 0
    require 'ruby-debug'; debugger
    @pages.each_with_index do |page, i|
      page_name = "americanseashell_%.4d.txt" % i
      f = open(File.join(File.dirname(__FILE__), 'pages', page_name), "w:utf-8") 
      f.write(page.join(""))
      f.close
      page.each do |l|
        no_start_tag = no_end_tag = false
        until no_start_tag && no_end_tag
          l.index(@start_tag)
        end
        @cursor += l.size
      end
    end
  end
end


r = Reader.new

r.find_offsets
