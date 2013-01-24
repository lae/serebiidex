#!/usr/bin/ruby
require 'optparse'

root = 'http://www.serebii.net/pokedex-bw/'
pokedex = Marshal.load File.read('pokedex.bin')

opts = {}
OptionParser.new do |o|
    o.banner = "usage searchdex.rb [options]"
    o.on('--id MATCH', 'Search by ID') { |id| opts[:id] = id }
    o.on('-h', 'Show this help') { puts '',o,''; exit }
    o.parse!
end

=begin
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
=end

if opts.length == 0
    puts "No options given."
    exit
end

def print_dex(entry)
    e = entry[0]
    types = e['types'].map {|t| t.capitalize }.join(', ')
    abilities = e['abilities'].join(', ')
    puts "======== #%03d - %s" % [e['num'], "#{e['name']} ".ljust(48, '=')]
    puts "       Types: #{types}"
    puts "   Abilities: #{abilities}"
end

if id = opts[:id]
    print_dex(pokedex.select {|dex| dex['num'] == id.to_i})
end
