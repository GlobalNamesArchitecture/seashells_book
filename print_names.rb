#!/usr/bin/env ruby
require 'yaml'

offsets = YAML.load(open('offsets.yml').read)

offsets.each do |o|
  if o[:start_page] == o[:end_page]
    f = open('pages/%s' % o[:start_page]).read
    puts "page: '%s', name: %s" % [o[:start_page], f[o[:start_tag]..o[:end_tag]]]
  end
end

