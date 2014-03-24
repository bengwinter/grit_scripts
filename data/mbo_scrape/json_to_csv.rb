require 'rubygems'
require 'csv'
require 'json'
require 'date'
require 'open-uri'


json = JSON.parse(IO.read("/Users/benwinter/Code/Shelton/production_code/data_collection/data/mbo_scrape/gyms.json"))


csv_array = []

json.each do |gym|
  array = []
  array << gym["name"] << gym["location"] << gym["industry"]
  csv_array << array
end



CSV.open("./gyms.csv", "w") do |csv|
  csv_array.each do |array|
    csv << array
  end
end

