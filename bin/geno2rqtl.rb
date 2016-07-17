#! /usr/bin/env ruby
#
# Convert a GN .geno file to R/qtl format. Example
#
# ruby geno2rqtl.rb cross.geno
#
# will write cross_geno.csv, cross_gmap.csv and cross.yaml
#
# you can pass in multiple .geno files

require 'json'

ARGV.each do |fn|
  h = {}
  inds = cols = nil
  print "Parsing #{fn}\n"
  base = File.basename(fn,".geno")
  geno = base + '_geno.csv'
  gmap = base + '_gmap.csv'
  gjson = base + ".json"
  geno_f = File.open(geno,"w")
  gmap_f = File.open(gmap,"w")

  print "Writing #{geno}, #{gmap}...\n"
  count = 0
  File.open(fn).each_line do |l|
    if l =~ /^#/
      # ---- Remark
      next
    elsif l =~ /^@(\S+):(\S+)/
      # ---- Header meta-info
      h[$1] = $2
    elsif l =~ /Chr\tLocus/i
      # ---- Column info
      cols = l.chomp.split(/\t/)
      p cols
      inds = cols[4..-1]
      # p inds
      geno_f.write((["marker"]+inds).join(",")+"\n")
      gmap_f.write("marker,chr,pos,Mb\n")
    else
      # ---- Genotypes
      count += 1
      fields = l.chomp.split(/\t/)
      # p fields
      geno_f.write(fields[1])
      raise "Comma not allowed in marker name" if fields[1] =~ /,/
      geno_f.write(","+fields[4..-1].join(","))
      geno_f.write("\n")

      gmap_f.write([fields[1],fields[0],fields[2],fields[3]].join(",")+"\n")
    end
  end
  p h
  print "Writing #{gjson}...\n"
  # R/qtl supports riself, f2, do...
  crosstype =
    case h["type"]
    when "riset" then "riself"
    else
      h["type"]
    end
  prefix = "genotypes/#{h["name"]}/"
  h2 = {
    description: h["name"],
    crosstype: crosstype,
    geno: prefix+"geno.csv",
    geno_transposed: true,
    genotypes_descr: {
      maternal: 1, paternal: 2, heterozygous: 3
    },
    genotypes: {
      h["mat"] => 1,
      h["pat"] => 2,
      h["het"] => 3
    },
    "x_chr": "X",
    "na.strings": [h["unk"]],
    gmap: prefix+"gmap.csv"
  }
  gjson_f = File.open(gjson,"w")
  gjson_f.print h2.to_json
end
