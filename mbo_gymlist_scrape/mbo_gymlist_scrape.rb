require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'
require 'json'
require 'date'
require 'watir'
require 'watir-webdriver'


cities = {"CAMBRIDGE" => "US|MA", "BROOKLINE" => "US|MA", "BROOKLINE & CAMBRIDGE" => "US|MA", "SOMMERVILLE" => "US|MA", "SOMERVILLE" => "US|MA", "ALLSTON" => "US|MA", "JAMAICA PLAIN" => "US|MA", "JAMAICA PLAINS" => "US|MA", "SOUTH BOSTON" => "US|MA", "CHARLESTOWN" => "US|MA", "ALLSTON" => "US|MA", "CHESTNUT HILL" => "US|MA", "CHESTNUTT HILL" => "US|MA", "NEWTON" => "US|MA", "NEWTON CENTRE" => "US|MA", "NEWTON CENTER" => "US|MA", "NEWTON HIGHLANDS" => "US|MA", "NEWTONVILLE" => "US|MA", "MEDFORD" => "US|MA", "NATICK" => "US|MA", "WATERTOWN" => "US|MA", "WELLESLEY" => "US|MA", "WELLESEY" => "US|MA", "WEST NEWTON" => "US|MA", "WELLESLEY HILLS" => "US|MA", "NEEDHAM" => "US|MA", "NEEDHAM HEIGHTS" => "US|MA", "BOSTON, MEDFIELD, NEWTON" => "US|MA"}
@location = {"BOSTON" => "Boston", "CAMBRIDGE" => "Cambridge", "BROOKLINE" => "Brookline", "BROOKLINE & CAMBRIDGE" => "Brookline/Cambridge", ""}
industries = {"OS" => "Yoga", "PS" => "Pilates", "FI" => "Health Club", "SS" => "Dance", "PT" => "Personal Trainer", "MA" => "Martial Arts", "WC" => "Wellness/Health Center", "O" => "Other"}

browser = Watir::Browser.new :firefox
browser.goto 'https://clients.mindbodyonline.com/ASP/finder.asp'
sleep(2.0)
browser.frame.select_list(css: '#Select1').select_value("US")
sleep(1.0)
cities.each do |city, state|
  skip_count = 0
  browser.frame.select_list(css: '#optStateProv').select_value(state)
  sleep(1.0)
  browser.frame.select_list(css: '#optCity').select_value(city)
  industries.each do |code, industry|
    if skip_count = 0
    else
      browser.frame.select_list(name: 'optSWType').select_value(code)
      sleep(1.0)
    end
    binding.pry
    browser.frame.input(type: "submit").click
    until browser.frame.h3(text: "Live Online Clients").parent.table.tbody.tr.td.exists? do
      sleep(1.0)
    end
    num_page_desc = browser.frame.h3(text: "Live Online Clients").parent.table.tbody.tr.td.text
    number_of_pages = num_page_desc[(num_page_desc.length - 1)]

    x = 1
    (number_of_pages).to_i.times do
      until browser.frame.h3(text: "Live Online Clients").parent.exists? do
        sleep(1.0)
      end
      doc = Nokogiri::HTML(browser.frame.h3(text: "Live Online Clients").parent.html)
      
      y = 1
      table_length = doc.css('tbody')[1].children.length
      until y > (table_length - 3) do
        doc.css('tbody')[1].children[y]
    
        gym_hash = {}
        gym_hash[:name] = doc.css('tbody')[1].children[y].children[2].children[1].children[1].children[1].children.text
        gym_hash[:location] = @location[city]
        gym_hash[:address] = "" 
        gym_hash[:city] = "" 
        gym_hash[:state] = "" 
        gym_hash[:zip_code] = "" 
        gym_hash[:phone_number] = ""
        gym_hash[:hours] = "" 
        gym_hash[:url] = doc.css('tbody')[1].children[y].children[0].children[1].attributes['href'].value
        gym_hash[:course_url] = "" 
        gym_hash[:mbo_url] = doc.css('tbody')[1].children[y].children[2].children[1].children[1].attributes['href'].value
        gym_hash[:industry] = industry
        gym_hash[:mbo_id] = gym_hash[:mbo_url][(organization_hash[:mbo_url].index('=') + 1), (organization_hash[:mbo_url].length - 1)]
        gym_hash[:scrape_freq] = 0

        File.open("./gyms.json","ab") do |f|
          f.write(gym_hash.to_json)
        end
        y += 3
      end
      

      x += 1
      begin
        browser.frame.link(href: "javascript:goToPage(#{x.to_s});").click
      rescue
      end
    end
    sleep(5.0)
    skip_count += 1
  end
  sleep(10.0)
end