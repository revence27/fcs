#!  /usr/bin/env ruby

require 'biblib'
require 'nokogiri'
require 'set'

def sort_occurrences text
  doc = Nokogiri::XML(text)
  dat = doc.xpath('/dictionary/item').inject({}) do |p, n|
    sid = n.xpath('strong_id').text
    if sid =~ /^G/ then
      sid = sid.gsub(/\D/, '')
      ans = n.xpath('description').inject(Set.new) do |st, dsc|
        dsc.xpath('link').each do |x|
          if x['target'] =~ /^G/ then
            st << x['target'].gsub(/\D/, '')
          end
        end
        st
      end
      p[sid]  = ans
    end
    p
  end
end

class Hash
  def topological
    seen  = []
    self.keys.each_with_index do |k, kix|
      ix  = seen.index k
      unless ix then
        ix    = seen.length
        seen  = seen + [k]
      end
      self[k].each do |mom|
        mix   = seen.index mom
        $stderr.puts %[Sorting under #{k}: #{mom} ...]
        seen  = if mix then
          if mix > ix then
            seen[0 .. ix - 1] + [mom] + seen[ix .. mix - 1] + seen[mix + 1 .. -1]
          else
            seen
          end
        else
          [mom] + seen
        end
      end
    end
    seen
  end
end

def main args
  args.each do |arg|
    File.open arg do |fich|
      them  = sort_occurrences(fich.read)
      them.topological.each do |key|
        puts key
        # puts(%[%5d\t%s] % [key.to_i, them[key].inspect])
      end
    end
  end
  0
end

exit(main(ARGV))
