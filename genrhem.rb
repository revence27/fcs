#!  /usr/bin/env ruby
#	encoding: utf-8

require 'biblib'
require 'erb'
require 'haml'
require 'nokogiri'
require 'pathname'

class String
  def no_verse_corrections
    self.gsub(/\[\s*\d+:\d+\D?\s*\]/, '')
  end

  def small_cap_caps
    self.gsub(/([A-Z]{2,})/) do |mtc|
      if mtc.length < 3 then
        '<span class="makemetinycaps">%s</span>' % [mtc]
      else
        '<span class="makemesmallcaps">%s</span>' % [mtc.capitalize]
      end
    end
  end

  def treat_verse
    self.strip.no_verse_corrections.gsub(/•([^•]+)•/, '<span class="mozzie">\1</span>').gsub(/{([^}])+}/, '<span class="heb">\1</span>').gsub(/\s*-\s+/, '—').gsub(/^Pause\./, '<span class="pause">Pause.</span>').gsub("'", '’').gsub(/\[([^\]]+)\]/, '<i>\1</i>').small_cap_caps
  end

  def make_poem_pieces *pts
    mpc self, pts
  end

  private
  def splitter dat, part
    return [] if dat[:text].strip == ''
    pts = dat[:text].split(part, 2)
    if pts.length < 2 then
      [{text: dat[:text], pre: dat[:pre], post: dat[:post]}]
    else
      [{text: pts.first, pre: dat[:pre], post: part}] + splitter({text: pts.last, pre: dat[:pre], post: dat[:post]}, part)
    end
  end

  def mpc s, parts
    sofar = [{text:s, pre: '', post: ''}]
    parts.each do |part|
      sofar = sofar.inject([]) do |p, n|
        p + splitter(n, part)
      end
    end
    sofar
  end
end

class Rhema
  attr_reader :name, :first, :last, :licence, :signature, :subtitle
  def initialize name, lic, images, cues, sbt, sig
    @name         = name
    @licence      = lic
    @signature    = sig
    @subtitle     = sbt
    @cues         = cues
    @first, @last = Bible.new(name), Bible.new(name)
    @images       = images
    load_image_captions!
    load_cues!
    yield self, @first, @last
  end

  def marking_cues bix, cix = nil, vix = nil
    pick_cues(@marks, bix, cix, vix)
  end

  def thinking_cues bix, cix = nil, vix = nil
    pick_cues(@thinks, bix, cix, vix)
  end

  def hand_cues bix, cix = nil, vix = nil
    pick_cues(@hand, bix, cix, vix)
  end

  def heading_cues bix, cix = nil, vix = nil
    pick_cues(@headings, bix, cix, vix)
  end

  def poetry_cues bix, cix = nil, vix = nil
    pick_cues(@pcues, bix, cix, vix)
  end

  def book_styling str, bix, book
    'stylised'
  end

  def chapter_styling str, bix, book, cix, chap = nil
    'stylised'
  end

  def chapter_illustration str, bix, book, cix, chap = nil
    bnom  = book.name
    # impth = ('%s-%d.jpg' % [bnom.gsub(' ', '-').downcase, cix + 1])
    impth = '%d:%d' % [bix + 1, cix + 1]
    capt  = @captions[impth]
    if capt then
      pn    = Pathname.new(@images['directory']) + capt.first
      if pn.file? then
        str %
        [if capt.last =~ /^\d+/ then    # if capt.last =~ /^\d+$/ then
          if chap.nil? then
            %[%s %d:%d] % [bnom, cix + 1, capt.last.to_i]
          else
            # chap[:verses][capt.last.to_i - 1][:text].gsub('[', '').gsub(']', '') rescue (%[%s %d:%d] % [bnom, cix + 1, capt.last.to_i])
            ans = capt.last.split(/\s+/).inject('') do |p, n|
              p + ' ' + (chap[:verses][n.to_i - 1][:text].gsub('[', '').gsub(']', '') rescue (%[%s %d:%d] % [bnom, cix + 1, n.to_i]))
            end
            # $stderr.puts('%s %s' % ['%s %d' % [bnom, cix + 1], ans])
            ans
          end
        else
          capt.last.treat_verse
        end, pn.to_s].map {|x| x.inspect}
      else
        ''
      end
    else
      ''
    end
  end

  protected
  def pick_cues box, bix, cix, vix
    set, key = if cix.nil? then
      [:books, (bix + 1).to_s]
    else
      if vix.nil? then
        [:chapters, '%d:%d' % [bix + 1, cix + 1]]
      else
        [:verses, '%d:%d:%d' % [bix + 1, cix + 1, vix + 1]]
      end
    end
    it  = box[set]
    if it.is_a?({}.class) then
      it[key]
    else
      it.member?(key)
    end
  end

  private
  def load_cues!
    @pcues    = {books: Set.new, chapters: Set.new, verses: Set.new}
    @headings = {books: {},      chapters: {},      verses: {}}
    @marks    = {                                   verses: Set.new}
    @thinks   = {                                   verses: Set.new}
    @hand     = {                                   verses: Set.new}
    [
      ['poetry', @pcues],
      ['headings', @headings],
      ['marks', @marks],
      ['thinks', @thinks],
      ['handofgod', @hand]
    ].each do |href|
      Pathname.new(@cues[href.first]).open do |fch|
        dest  = href.last
        fch.each_line do |ligne|
          mrk, rst    = ligne.split(/\s+/, 2)
          bk, chp, vx = mrk.split ':'
          putin       = dest[if vx.nil? then
            if chp.nil? then
              :books
            else
              :chapters
            end
          else
            :verses
          end]
          if putin.is_a?({}.class) then
            putin[mrk] = rst.strip
          else
            putin << mrk
          end
        end
      end
    end
  end

  def load_image_captions!
    @captions = {}
    (Pathname.new(@images['directory']) + @images['captions']).open do |fch|
      fch.each_line do |ligne|
        key, pth, val  = ligne.strip.split(/\s+/, 3)
        unless key.nil? then
          @captions[key.strip]  = [pth, val.to_s.strip]
        end
      end
    end
  end
end

class Devotional
  def initialize fch
    @doc  = File.open fch do |f|
      Nokogiri::XML(f.read)
    end
    @ref  = {}
  end

  def to_html devhaml
    @tout   = {}
    @dates  = []
    @doc.xpath('/devotional/day').each do |day|
      date  = day.xpath('date')[0].text.strip
      ans   = {}
      @dates  << date
      ans['morn'] = pull_reading day, 'morn'
      ans['even'] = pull_reading day, 'even'
      @tout[date] = ans
    end

    File.open devhaml do |fch|
      Haml::Engine.new(fch.read).render binding
    end
  end

  private
  def pull_reading doc, tag
    doc.xpath(tag).each do |got|
      hd  = got.xpath('main').text
      dem = []
      got.xpath('verses').each do |vs|
        vs.xpath('verse').each do |v|
          dem << v
        end
      end
      return {heading: hd, verses: dem}
    end
  end
end

class Lectionary
  def initialize fch
    @doc  = File.open fch do |f|
      Nokogiri::XML(f.read)
    end
    @ref  = {}
  end

  def to_html hpath
    @tout   = {}
    @dates  = []
    @doc.xpath('/lec/day').each do |day|
      date  = day.xpath('date').text.strip
      ans   = {}
      @dates  << date
      day.xpath('read').each do |rdg|
        ans[:nt] = rdg.text if rdg['part'] == 'nt'
        ans[:ot] = rdg.text if rdg['part'] == 'ot'
      end
      @tout[date] = ans
    end

    File.open hpath do |fch|
      Haml::Engine.new(fch.read).render binding
    end
  end
end

class Helpers
  def initialize rhema, robj
    @robj  = robj
    @rhema  = rhema
  end

  def devotional dev, devhaml
    dev = Devotional.new(dev)
    dev.to_html devhaml
  end

  def calendar lectionary, lechaml
    lec = Lectionary.new(lectionary)
    lec.to_html lechaml
  end

  def index
    File.open((@rhema / 'index').first['href']) do |fch|
      Haml::Engine.new(fch.read).render(self.context)
    end
  end

  def ruled num = 5
    (0 ... num).to_a.inject("\n\t\t") do |p, n|
      %[#{p}<div class="line"></div>]
    end
  end

  def toc
    File.open((@rhema / 'toc').first['href']) do |fch|
      Haml::Engine.new(fch.read).render(self.context)
    end
  end

  def theology
    File.open((@rhema / 'appendage').first['href']) do |fch|
      Haml::Engine.new(fch.read).render(self.context)
    end
  end

  def preface
    File.open((@rhema / 'preface').first['href']) do |fch|
      Haml::Engine.new(fch.read).render(self.context)
    end
  end

  def context
    binding
  end
end

def main args
  if args.empty? then
    $stderr.puts %[#{$0} rhema.xml [...]]
    return 1
  end

  args.each do |arg|
    File.open arg do |fich|
      doc   = Hpricot.XML(fich)
      rhema = (doc / 'rhema').first
      robj  = Rhema.new(rhema['name'], rhema['licence'] || 'Public Domain', (rhema / 'images').first, (rhema / 'cues').first, (rhema / 'sub').first.inner_html, (rhema / 'sig').first.inner_html) do |r, first, last|
        File.open((rhema / 'top').first['href']) {|top| first.process! top, r}
        File.open((rhema / 'bottom').first['href']) {|bottom| last.process! bottom, r}
      end
      rhtml = (rhema / 'rhtml').first
      File.open(rhtml['href']) do |rfich|
        erb = ERB.new rfich.read
        File.open(rhtml['to'], 'w') {|html| html.write(erb.result(Helpers.new(rhema, robj).context))}
      end
    end
  end

  0
end

exit(main(ARGV))
