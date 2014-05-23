#!  /usr/bin/env ruby

def pmain args
  perc  = false
  max   = 0
  $stdin.each_line do |ligne|
    $stdout.puts ligne
    $stdout.flush
    gots  = ligne.strip
    goti  = gots.to_i
    msg   = ''
    perc  = true if goti < max
    if perc then
      msg = '%d%%' % [(goti.to_f / max.to_f).round(2)]
    else
      max = goti unless max >= goti
      msg = max.to_s
    end
    # $stdout.write %[\r #{msg}           \r]
    # $stdout.flush
  end
  $stdout.puts
  0
end

exit(pmain(ARGV))
