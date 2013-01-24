#!/usr/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'

root = 'http://www.serebii.net/pokedex-bw/'
c = 1
pokedex = Array.new

def rs(s, index = 0)
    s = s.css('td[align=center]')
    if ! index.nil?
        return s.map { |d| d.text.split(/ - /)[index] }
    else
        return s.map { |d| d.text }
    end
end

while c <= 649 do
    uri = "%s%03d.shtml" % [root, c]
    page = Nokogiri::HTML(open(uri))
    info = page.css('.dextable')[1].css('.fooinfo')
    stats = page.css('.dextable')[-1].css('tr')
    pokedex << p = Hash.new
    p.store('num', c)
    p.store('name', info[0].text)
    p.store('types', info[4].css("img").map { |d| d['src'].split(/\.|\//)[3] })
    p['stats'] = { 'base' => rs(stats[2]),
        'hindering_min' => rs(stats[4], 0),
        'hindering_max' => rs(stats[4], 1),
        'neutral_min' => rs(stats[6], 0),
        'neutral_max' => rs(stats[6], 1),
        'beneficial_min' => rs(stats[8], 0),
        'beneficial_max' => rs(stats[8], 1) }
    p.store('abilities', info[5].css('a b').map { |d| d.text })
    c = c.next
end

serialized_pokedex = Marshal.dump(pokedex)
File.open('pokedex.txt', 'w') {|f| f.write(serialized_pokedex) }
