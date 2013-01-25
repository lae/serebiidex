#!/usr/bin/ruby
require 'optparse'

@root = 'http://www.serebii.net/pokedex-bw/'
pokedex = Marshal.load File.read('pokedex.bin')
abilitydex = Marshal.load File.read('abilitydex.bin')

@opts = {}
OptionParser.new do |o|
    o.banner = "usage searchdex.rb [options]"
    o.on('--abilitydex', '-a', 'Search Ability Dex') { @opts[:adex] = true }
    o.on('--id ID', 'Search by ID') { |id| @opts[:id] = id }
    o.on('--name NAME', '-n', 'Search by NAME') { |n| @opts[:name] = n }
    o.on('--ability ABILITY', 'Search by ABILITY') { |a| @opts[:ability] = a }
    o.on('--type TYPES', '-t', 'Search by comma-delimited TYPES') {|t| @opts[:type] = t.split(',') }
    o.on('--stat-display STATS', '-D', 'Limit statistics display to comma-delimited STATS') {|s|
        @opts[:sd] = []
        l = %w{h hmin hmax n nmin nmax b bmin bmax}
        s = s.split(',')
        abort('Invalid values passed to --stat-display') if !s.all? {|v| l.include?(v) }
        s.each {|v|
            if v.length == 1
                @opts[:sd] << "#{v}min"
                @opts[:sd] << "#{v}max"
            else
                @opts[:sd] << v
            end
        }
    }
    o.on('--no-prompt', 'Don\'t show any prompts') { @opts[:noprompt] = true }
    o.on('-h', 'Show this help') { puts '',o,''; exit }
    o.parse!
end

@opts[:sd] = %w{hmin hmax nmin nmax bmin bmax} if !@opts[:sd]

@immunities = { 'normal' => 'Ghost', 'flying' => 'Ground', 'ground' => 'Electric', 'ghost' => 'Normal, Fighting', 'steel' => 'Poison', 'dark' => 'Psychic' }

def print_dex(entry)
    e = entry
    types = e['types'].map {|t| t.capitalize }.join(', ')
    abilities = e['abilities'].join(', ')
    immunities = e['types'].map {|t| @immunities[t] }.compact.join(', ')
    shmin = e['stats']['hindering_min']
    snmax = e['stats']['hindering_max']
    snmin = e['stats']['neutral_min']
    shmax = e['stats']['neutral_max']
    sbmin = e['stats']['beneficial_min']
    sbmax = e['stats']['beneficial_max']
    puts "======== #%03d - %s #{@root}%03d.shtml" % [e['num'], "#{e['name']} ".ljust(48, '='), e['num']]
    puts "       Types: #{types}"
    puts "  Immunities: #{immunities}" if immunities.length > 0
    puts "   Abilities: #{abilities}"
    puts "  STATISTICS  HP   - %s" % ["Attack", "Defense", "Sp. Atk.", "Sp. Def.", "Speed"].map { |h| h.ljust(9) }.join('- ')
    puts "    hindered- %3d  - %s" % [shmin[0], shmin[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('hmin')
    puts "    hindered+ %3d  - %s" % [shmax[0], shmax[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('hmax')
    puts "     neutral- %3d  - %s" % [snmin[0], snmin[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('nmin')
    puts "     neutral+ %3d  - %s" % [snmax[0], snmax[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('nmax')
    puts "  beneficial- %3d  - %s" % [sbmin[0], sbmin[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('bmin')
    puts "  beneficial+ %3d  - %s" % [sbmax[0], sbmax[1..5].map { |s| s.ljust(9) }.join('- ') ] if @opts[:sd].include?('bmax')
    puts ''
end

def print_adex(entry)
    e = entry
    puts "========%s" % " #{e[0]} ".ljust(56, '=')
    puts " Description: #{e[1]}", "      Effect: #{e[2]}", ''
end

if @opts[:adex]
    if @opts[:name]
        abilitydex.select {|dex| dex[0] =~ /#{@opts[:name]}/i}.each {|e| print_adex(e)}
    else
        puts "You didn't specify an ability using -n."
    end
    exit
end

filter = pokedex
filter = filter.select {|dex| dex['num'] == @opts[:id].to_i} if @opts[:id]
filter = filter.select {|dex| dex['name'] =~ /#{@opts[:name]}/i} if @opts[:name]
filter = filter.select {|dex| dex['abilities'].any? {|a| a =~ /#{@opts[:ability]}/i}} if @opts[:ability]
filter = filter.select {|dex| @opts[:type].all? {|t| dex['types'].any? {|d| d =~ /#{t}/i }}} if @opts[:type]
if filter.length == pokedex.length
    print 'Are you sure you want to print the entire Pokedex? ' unless !@opts[:noprompt].nil?
    p = @opts[:noprompt].nil?? STDIN.gets.chomp : 'y' 
    filter.each {|e| print_dex(e)} if p == 'y'
elsif filter.length > 100
    print 'Your constraints matched over 100 Pokemon. Do you still want to print these entries? ' unless !@opts[:noprompt].nil?
    filter.each {|e| print_dex(e)} if STDIN.gets.chomp == 'y' or @opts[:noprompt].nil?
elsif filter.length > 0
    filter.each {|e| print_dex(e)}
else
    puts "Your constraints did not match any Pokemon."
end
