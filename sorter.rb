#!  /usr/bin/env ruby

require 'biblib'

def main args
  args.each do |arg|
    File.open arg do |fich|
      list  = []
      fich.each_line do |ligne|
        code, _ = ligne.split('#', 2)
        word, gnum, rmac, cnt, ref = code.strip.split("\t")
        list << [gnum, cnt.to_i, word]
      end
      list.sort do |l, r|
        r[1] <=> l[1]
      end.map do |mem|
        $stdout.puts("%s\tG%d" % [mem[2], mem[0]])
      end
    end
  end
  0
end

exit(main(ARGV))
