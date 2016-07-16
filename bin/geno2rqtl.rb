#! /usr/bin/env ruby
#
# Convert a GN .geno file to R/qtl format. Example
#
# ruby geno2rqtl.rb cross.geno
#
# will write cross_geno.csv, cross_gmap.csv and cross.yaml

in_header = true
h = {}
inds = cols = nil

ARGV.each do |fn|
  print "Parsing #{fn}\n"
  File.open(fn).each_line do |l|
    l =~ /^@(\S+):(\S+)/
    if $1
      h[$1] = $2
    elsif l =~ /Chr\tLocus/i
      cols = l.chomp.split(/\t/)
      # p cols
      inds = cols[4..-1]
      # p inds
    else
      fields = l.chomp.split(/t/)
      p fields
    end
  end
end
p h
p inds
