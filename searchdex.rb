#!/usr/bin/ruby
require 'optparse'

root = 'http://www.serebii.net/pokedex-bw/'
pokedex = Marshal.load File.read('pokedex.bin')
abilitydex = Marshal.load File.read('abilitydex.bin')

opts = {}
OptionParser.new do |o|
    o.banner = "usage searchdex.rb [options]"
    o.on('--abilitydex', '-a', 'Search Ability Dex') { opts[:adex] = true }
    o.on('--id ID', 'Search by ID') { |id| opts[:id] = id }
    o.on('--name NAME', '-n', 'Search by NAME') { |n| opts[:name] = n }
    o.on('-h', 'Show this help') { puts '',o,''; exit }
    o.parse!
end

if opts.length == 0
    puts "No options given."
    exit
end

def print_dex(entry)
    e = entry[0]
    types = e['types'].map {|t| t.capitalize }.join(', ')
    abilities = e['abilities'].join(', ')
    shmin = e['stats']['hindering_min']
    snmax = e['stats']['hindering_max']
    snmin = e['stats']['neutral_min']
    shmax = e['stats']['neutral_max']
    sbmin = e['stats']['beneficial_min']
    sbmax = e['stats']['beneficial_max']
    puts "======== #%03d - %s" % [e['num'], "#{e['name']} ".ljust(48, '=')]
    puts "       Types: #{types}"
    puts "   Abilities: #{abilities}",''
    puts ' '*12 + "STATISTICS".center(52)
    puts "              HP   - %s" % ["Attack", "Defense", "Sp. Atk.", "Sp. Def.", "Speed"].map { |h| h.ljust(9) }.join('- ')
    puts "    hindered- %3d  - %s" % [shmin[0], shmin[1..5].map { |s| s.ljust(9) }.join('- ') ]
    puts "    hindered+ %3d  - %s" % [shmax[0], shmax[1..5].map { |s| s.ljust(9) }.join('- ') ]
    puts "     neutral- %3d  - %s" % [snmin[0], snmin[1..5].map { |s| s.ljust(9) }.join('- ') ]
    puts "     neutral+ %3d  - %s" % [snmax[0], snmax[1..5].map { |s| s.ljust(9) }.join('- ') ]
    puts "  beneficial- %3d  - %s" % [sbmin[0], sbmin[1..5].map { |s| s.ljust(9) }.join('- ') ]
    puts "  beneficial+ %3d  - %s" % [sbmax[0], sbmax[1..5].map { |s| s.ljust(9) }.join('- ') ]
end

def print_adex(entry)
    e = entry
    puts "========%s" % " #{e[0]} ".ljust(56, '=')
    puts " Description: #{e[1]}", "      Effect: #{e[2]}"
end

if opts[:adex]
    if opts[:name]
        abilitydex.select {|dex| dex[0] =~ /#{opts[:name]}/i}.each {|e| print_adex(e)}
    else
        puts "You didn't specify an ability using -n."
    end
else

if id = opts[:id]
    print_dex(pokedex.select {|dex| dex['num'] == id.to_i})
end

end
