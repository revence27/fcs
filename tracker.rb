#!  /usr/bin/env ruby

def tmain args
  pct   = false
  app   = '%'
  cols  = 75
  pred  = ' '
  posd  = ' '
  if args.length > 0 then
    if args.length != 3 then
      $stderr.puts %[#{$0} [columns left-indicator right-indicator]\n\tProvide all three optional args, or none of them.\n\tDefaults: #{cols} '#{pred}' '#{posd}'\n\tindicators presume single printable character.]
      return 1
    end
    cols  = args.shift.to_i
    pred  = args.shift
    posd  = args.shift
  end
  STDIN.each do |ligne|
    key, dat  = ligne.strip.split('|', 2)
    if key == 'prg' then
      if dat =~ /^\d+$/ then
        pct   = true
        dig   = dat.to_i.to_f
        # prep  = "#{pred}"[0, 1] * [(((dig / 100.0) * cols).to_i - (dat.length + app.length)), 0].max
        # trk   = %[\r#{prep}#{dat}#{app}#{"#{posd}"[0, 1] * 1000}][0, cols]
        prep  = "#{pred}" * [(((dig / 100.0) * cols).to_i - (dat.length + app.length)), 0].max
        trk   = %[\r#{prep}#{dat}#{app}#{"#{posd}" * 1000}][0, cols]
        $stdout.write trk
        $stdout.flush
      else
        $stdout.puts if pct
        $stdout.puts ligne
        pct = false
      end
    else
      $stdout.puts if pct
      $stdout.puts ligne
      pct = false
    end
  end
  $stdout.puts
  0
end

exit(tmain(ARGV))
