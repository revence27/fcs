#!  /usr/bin/env ruby

require 'biblib'
require 'json'

def main args
  args.each do |arg|
    File.open arg do |fich|
      @bible  = Bible.new('')
      @bible.process! fich
      $stdout.puts(JSON.generate(@bible.to_hash))
    end
  end
  0
end

exit(main(ARGV))
