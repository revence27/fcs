#!  /usr/bin/env ruby

class String
  def deusfm
    self.gsub(/\\\S+/, '')
  end
end

def umain args
  if args.length < 2 then
    $stderr.puts %[#{$0} first-pos file1.usfm [file2.usfm ...]]
    return 1
  end
  stt   = args.shift.to_i
  seen  = false
  prevs = ''
  $stdout.puts %[<?xml version="1.0" ?>\n<XMLBIBLE>]
  args.each do |arg|
    File.open arg do |fch|
      fch.each_line do |ligne|
        key, etc  = ligne.strip.split(' ', 2)
        if key == '\\h' then
          $stdout.puts %[\n\t</BIBLEBOOK>] if seen
          $stdout.puts %[\t<BIBLEBOOK bnumber="#{stt}" bname="#{etc}">]
          seen  = true
          stt   = stt + 1
        else
          if key == '\\c' then
            $stdout.puts %[\n\t\t</CHAPTER>] unless etc.to_i == 1
            $stdout.puts %[\t\t<CHAPTER cnumber="#{etc}">]
          else
            if key == '\\v' then
              vs, oth = etc.split(' ', 2)
              $stdout.puts %[</VERS>] unless vs.to_i == 1
              $stdout.write %[\t\t\t<VERS vnumber="#{vs}">#{oth.to_s.deusfm}]
            else
              if not ligne =~ /^\\/ then
                $stdout.puts ligne.deusfm
              elsif key =~ /\\q\d?/ or ['\\p', '\\pi'].member? key then
                $stdout.write(' %s' % [etc.to_s.deusfm])
              else
                $stderr.puts ligne.deusfm if key == '\\nb'
              end
            end
          end
        end
      end
      $stdout.puts %[</VERS>\n\t\t</CHAPTER>\n\t</BIBLEBOOK>]
    end
  end
  $stdout.puts %[</XMLBIBLE>]
  0
end

exit(umain(ARGV))
