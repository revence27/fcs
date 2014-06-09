#!  /usr/bin/env ruby

require 'hpricot'

class Book
  attr_reader :name
  attr_accessor :sname, :chapters
  attr_writer :head
  def initialize name
    @name     = name
    @sname    = name.gsub(' ', '')[0, 4]
    @chapters = []
    @head     = nil
  end
  
  def head
    return nil unless @head
    @head.gsub(/\[([^\]]+)\]/, '<div class="teensy">\1</div>')
  end

  def << chap
    @chapters << chap
  end
end

class Bible
  attr_reader :books, :name
  def initialize name
    @name     = name
  end

  def to_hash
    {name: @name, books: @books.map {|book| {name: book.name, chapters:book.chapters, sname:book.sname}}}
  end

  def process! fich, hlp
    doc     = Hpricot.XML(fich)
    @books  = []
    @name   = (doc / 'XMLBIBLE').first['biblename'] || @name
    (doc / 'BIBLEBOOK').each_with_index do |book, bix|
      bk  = Book.new(book['bname'] || ('Book #%d' % [bix + 1]).to_s)
      bhd = hlp.heading_cues(bix)
      if bhd then
        bk.head = bhd
      end
      chapters  = []
      bpoem     = hlp.poetry_cues(bix)
      (book / 'CHAPTER').each_with_index do |chapter, cix|
        verses  = []
        cpoem   = hlp.poetry_cues(bix, cix)
        (chapter / 'VERS').each_with_index do |verse, vix|
          mark          = {text: verse.inner_html.strip}
          mark[:mark]   = hlp.marking_cues(bix, cix, vix)
          mark[:think]  = hlp.thinking_cues(bix, cix, vix)
          ppoem         = hlp.poetry_cues(bix, cix, vix)
          mark[:poem]   = true if ppoem or cpoem or bpoem
          mark[:hand]   = hlp.hand_cues(bix, cix, vix)
          hlpc          = hlp.heading_cues(bix, cix, vix)
          mark[:sh]     = hlpc if hlpc
          if mark[:poem] then
            mark[:pieces] = mark[:text].make_poem_pieces(': ', '; ', '? ', '?”', '.”', '. ', '!”', '! ')
          end
          verses[(verse['vnumber'] || vix + 1).to_i - 1] = mark
        end
        chvs  = {verses: verses}
        chd   = hlp.heading_cues(bix, cix)
        if chd then
          chvs[:title]  = chd
        end
        chapters[(chapter['cnumber'] || cix + 1).to_i - 1] = chvs
      end
      bk.chapters = chapters
      # @books << bk
      @books[(book['bnumber'] || bix + 1).to_i - 1] = bk
    end
  end
end
