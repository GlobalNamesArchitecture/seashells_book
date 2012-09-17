#!/usr/bin/env ruby
require 'yaml'

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
    @pages.each_with_index do |page, i|
      @cursor = 0
      page_name = "americanseashell_%.4d.txt" % i
      page_processed = []
      name_string = ''
      page.each do |l|
        l.gsub!(/<[\/]?tlawname>/, '')
        processed_line = ''
        no_start_tag = no_end_tag = false
        until no_start_tag && no_end_tag
          if @between_tags
            match = l.index(@end_tag)
            if match
              @cursor += match
              @offsets.last[:end_tag] = @cursor
              @offsets.last[:end_page] = page_name
              @offsets.last[:name_string] << l[0...match]
              processed_line << l[0...match]
              l = l[(match + @end_tag.size)..-1]
              @between_tags = false
            else
              @offsets.last[:name_string] << l[0..-1]
              @cursor += l.size
              no_end_tag = true
              no_start_tag = true
              processed_line << l
            end
          else
            match = l.index(@start_tag)
            if match
              @cursor += match
              @offsets << {:start_tag => @cursor, :name_string => '', :start_page => page_name}
              processed_line << l[0...match]
              l = l[(match + @start_tag.size)..-1]
              @between_tags = true
            else
              @cursor += l.size
              no_start_tag = true
              no_end_tag = true
              processed_line << l
            end
          end
        end
        # @cursor += processed_line.size
        page_processed << processed_line
      end
      f = open(File.join(File.dirname(__FILE__), 'pages', page_name), "w:utf-8") 
      f.write(page_processed.join(""))
      f.close
    end
    offsets = open('offsets.yml','w')
    offsets.write(YAML.dump(@offsets))
    offsets.close
  end
end


r = Reader.new

r.find_offsets
