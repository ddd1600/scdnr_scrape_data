require 'highline/import'

class ScrapeDnrData
  attr_reader :b, :county, :county_text_query_url, :hsh, :href, :countyary, :f, :arys, :done
  
  def initialize(b=nil)
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.dir'] = "#{Dir.pwd}/lib/assets/e00s"
    profile['browser.helperApps.neverAsk.saveToDisk'] = "application/octet-stream"
    @b = Watir::Browser.new :firefox, :profile => profile
    @b.goto "http://www.dnr.sc.gov/GIS/gisdownload.html"
    @b.a(:text => "DNR GIS Data Clearinghouse").click
    @b.text_field(:name => "pfirstname").set "David"
    @b.text_field(:name => "puserid").set "42533"
    @b.input(:value => "Verify").click
    @county_text_query_url = @b.a(:text => "County Text Query").href
    @arys = []
  end# of initialize
  
  def go(skips = [])
    @done = []
    County.where(:state => "SC").map(&:name).each do |county|
      next if skips.include?(county)
      puts "***\n#{county}\n***"
      go_for_county(county)
      @done << county
    end
    File.open("#{Rails.root}/DNR/dnr.json", 'a') {|f| f.write(@arys.to_json)}
  end
  
  def go_for_county(county)
    @b.goto @county_text_query_url #this is hub url 1, to be referred back to for each county visited/logged
    countyary = []
    @b.select_list(:name => "pcounty").select county
    @b.input(:name => "paction").click
    hsh = {}
    @b.options.map(&:value).each do |v| 
      hsh[v] = @b.select_lists[0].select_value(v)
    end
    hsh.each do |short, long|
      zonehsh = { :county => county, :zone_short => short }
      zonehsh[:zone_long] = @b.select_lists[0].select_value(short)
      countyary << zonehsh
    end
    ap countyary
    @arys << countyary
  end
  
  def save
    @f.close
  end
  
end# of class