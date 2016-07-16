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
  base = File.basename(fn,".geno")
  geno = base + '_geno.csv'
  gmap = base + '_gmap.csv'
  geno_f = File.open(geno,"w")
  gmap_f = File.open(gmap,"w")

  print "Writing #{geno}, #{gmap}...\n"
  count = 0
  File.open(fn).each_line do |l|
    l =~ /^@(\S+):(\S+)/
    if $1
      # ---- Header meta-info
      h[$1] = $2
    elsif l =~ /Chr\tLocus/i
      # ---- Column info
      cols = l.chomp.split(/\t/)
      p cols
      inds = cols[4..-1]
      # p inds
      geno_f.write((["id"]+inds).join(",")+"\n")
    else
      # ---- Genotypes
      count += 1
      fields = l.chomp.split(/\t/)
      p fields
      geno_f.write(fields[1])
      geno_f.write(","+fields[4..-1].join(","))
      geno_f.write("\n")
    end
  end
end
p h
p inds
