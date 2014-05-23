#!  /usr/bin/env ruby

require 'nokogiri'

def rmain args
  args.each do |arg|
    File.open arg do |fch|
      doc = Nokogiri::XML(fch.read)
      doc.xpath('/rhema').each do |rh|
        $stdout.puts rh['name']
      end
    end
  end
  0
end

exit(rmain(ARGV))
