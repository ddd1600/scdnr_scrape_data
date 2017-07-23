def go(county)
  Dir.chdir(county)
  files = Dir.glob("*.e00")
  files.each do |fn|
    basename = File.basename(fn, ".*")
    puts "decompressing e00 #{fn}..."
    shellcode = "e00conv #{basename}.e00 #{basename}_decompressed.e00"
    puts "about to try this in terminal: #{shellcode}"
    `#{shellcode}`
    puts "converting to shapefile..."
    `ogr2ogr #{basename}.shp #{basename}_decompressed.e00`
  end# of files
end# of go

ARGV.each do |arg|
  puts "running for #{arg}"
  go(arg)
end

    
    
  
  
