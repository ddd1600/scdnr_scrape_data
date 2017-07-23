require 'net/ftp'
require 'json'
require 'highline/import'

def go(counties=nil)
  counties ||= ["Horry", "Marion"]
  json = JSON.parse(File.open("townships.json").read).flatten
  puts "establishing ftp connection..."
  $ftp = Net::FTP.new("ftpdata.dnr.sc.gov")
  $ftp.login
  $ftp.chdir("gisdata/sls")
  fns = $ftp.ls.map{|str| str.split(" ")[-1]}

  counties.each do |c|
    puts "running for #{c}"
    townships = json.select{|hsh| hsh['county'] == c}
    n = townships.count
    townships.each_with_index do |hsh, i|
      print "\n#{i}/#{n}: " + hsh['zone_long'] + ", #{c} County..."
      township_shortname = hsh['zone_short'].downcase
      fn = fns.select{|str| str =~ /#{township_shortname}/}.first
      puts "fn is #{fn}"
      $ftp.get(fn, "#{c}/#{fn}")
    end# of townships
  end
end   

go
    
  
    
  