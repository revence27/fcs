#!  /usr/bin/env ruby

def emain args
  args.each do |arg|
    one, two, three, four = [], [], [], []
    File.open arg do |fch|
      fch.each_line do |ligne|
        pcs = ligne.strip.split /\s+/
        pc1 = []
        3.times do
          pc1 << pcs.shift
        end
        one << pc1.join(' ')
        pc2 = []
        3.times do
          pc2 << pcs.shift
        end
        two << pc2.join(' ')
        pc3 = []
        3.times do
          pc3 << pcs.shift
        end
        three << pc3.join(' ')
        pc4 = []
        3.times do
          pc4 << pcs.shift
        end
        four << pc4.join(' ')
      end
    end
    [one, two, three, four].each do |list|
      puts *list
    end
  end
  0
end

exit(emain(ARGV))
