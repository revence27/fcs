#!  /usr/bin/env ruby

require 'biblib'
require 'erb'

class Rhema
  attr_reader :name, :first, :last
  def initialize name
    @name         = name
    @first, @last = Bible.new(name), Bible.new(name)
    yield @first, @last
  end
end

def main args
  if args.empty? then
    $stderr.puts %[#{$0} rhema.xml [...]]
    return 1
  end

  args.each do |arg|
    File.open arg do |fich|
      doc    = Hpricot.XML(fich)
      rhema  = (doc / 'rhema').first
      @rhema = Rhema.new(rhema['name']) do |first, last|
        File.open((rhema / 'top').first['href']) {|top| first.process! top}
        File.open((rhema / 'bottom').first['href']) {|bottom| last.process! bottom}
      end
      rhtml = (rhema / 'rhtml').first
      File.open(rhtml['href']) do |rfich|
        erb = ERB.new rfich.read
        File.open(rhtml['to'], 'w') {|html| html.write(erb.result(binding))}
      end
    end
  end

  0
end

exit(main(ARGV))
