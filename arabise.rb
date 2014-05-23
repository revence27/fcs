#!  /usr/bin/env ruby

require 'erb'
require 'biblib'

def main args
  args.each do |arg|
    File.open arg do |fich|
      @bible  = Bible.new('')
      erb     = ERB.new DATA.read
      @arabiser = proc do |str|
        million.each do |
      end
      @bible.process! fich
      $stdout.puts(erb.result(binding))
    end
  end
  0
end

exit(main(ARGV))

__END__
<?xml version="1.0" encoding="utf-8"?>
<XMLBIBLE biblename="<%= @bible.name %>">
  <%  @bible.books.each_with_index do |book, bix| next unless book %>
    <BIBLEBOOK bnumber="<%= bix + 1 %>" bname="<%= book.name %>" bsname="<%= book.sname %>">
    <% book.chapters.each_with_index do |chapter, cix| %>
      <CHAPTER cnumber="<%= cix + 1 %>">
        <% chapter.each_with_index do |verse, vix| %><VERS vnumber="<%= vix + 1 %>"><%= @arabiser.call(verse[:text]) %></VERS>
      <% end %>
    </CHAPTER><% end %>
  </BIBLEBOOK><% end %>
</XMLBIBLE>
