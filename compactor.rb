#!  /usr/bin/env ruby

require 'biblib'
require 'set'

class StrongStore
  def words
    @them
  end

  def initialize
    @them = {}
  end

  def add word, gnum, rmac, ref
    got = @them[word]
    if got then
      return self if (got[:num] == gnum and got[:rmac].member?(rmac))
      got[:rmac] << rmac
      got[:refs] << ref
    else
      @them[word] = {num: gnum, refs:Set.new([ref]), rmac:Set.new([rmac])}
    end
    self
  end
end

def main args
  args.each do |arg|
    File.open arg do |fich|
      store = StrongStore.new
      fich.each_line do |ligne|
        code, _ = ligne.split('#', 2)
        word, gnum, rmac, ref = code.strip.split(' ')
        begin
          store.add(word.strip, gnum.to_i, rmac.downcase, ref.strip)
        rescue Exception => e
          $stderr.puts code
          next
        end
        # store.add(word.to_s.strip, gnum.to_i, rmac, ref.to_s.strip)
      end
      words = store.words
      words.keys.each do |word|
        piece = words[word]
        $stdout.puts("%s\t%d\t%s\t%d\t%s" % [word, piece[:num], piece[:rmac].to_a.join(','), piece[:refs].length, piece[:refs].to_a.join(',')])
      end
    end
  end
  0
end

exit(main(ARGV))
