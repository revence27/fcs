#!  /usr/bin/env ruby

require 'erb'
require 'json'

def main args
  args.each do |arg|
    File.open(arg) do |fich|
      erb = ERB.new(DATA.read)
      @books = JSON.parse(fich.read)
      $stdout.puts erb.result(binding)
    end
  end
  0
end

exit(main(ARGV))

__END__
<XMLBIBLE>
  <% @books.each_with_index do |book, ix| %><BIBLEBOOK bname="<%= book['book'] %>" bnumber="<%= ix + 1 %>">
    <% book['chapters'].each_with_index do |chapter, cix| %><CHAPTER cnumber="<%= cix + 1 %>">
      <% chapter.each_with_index do |verse, vix| %><VERS vnumber="<%= vix + 1 %>"><%= verse %></VERS>
      <% end %></CHAPTER>
    <% end %></BIBLEBOOK>
  <% end %></XMLBIBLE>
