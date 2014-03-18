require_relative '../db_connect.rb'

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Sports Club LA")[0]
browser = Watir::Browser.new :firefox

org.gyms.each do |gym|
  browser.goto gym["course_url"]
  @week.each do |day|
    @class_date = browser.div(css: "##{day}").div(css: '.dayname').span.text.gsub('(','').gsub(')','') + '/' + Time.now.year.to_s
    browser.div(css: "##{day}").divs(css: '.class').each do |course|
      course_data = Nokogiri::HTML(course.html)

      #course
      title = course_data.css('.name').text.gsub('*', '')
      paid = course_data.css('.name').text.include?('**') ? TRUE : FALSE
      categories = course_data.css('div')[0].attributes["class"].value.split
      level = course_data.css('.level').text + ": " + course_data.css('.level')[0].attributes["title"].text
      members_only = TRUE

      course.links[0].click
      description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
      browser.div(css: '.infobox_close').click

      #instructor
      first_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[0]
      last_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[1]
      personal_trainer = course_data.css('.instructor').text.include?('*') ? TRUE : FALSE
      substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE
      cerifications = []
      accomplishments = []
      philosophy = "Not Provided"
      gender = "Not Provided"
      birthday = "Not Provided"
      email = "Not Provided"
      phone_number = "Not Provided"
      address = "Not Provided"
      city = "Not Provided"
      state = "Not Provided"
      zip_code = "Not Provided"

      course.links[1].click
      description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
      raw_description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
      browser.div(css: '.infobox_close').click

      #section
      start_time = course_data.css('.time').text.split[0].gsub('am', ' AM').gsub('pm', ' PM')
      end_time = course_data.css('.time').text.split[2].gsub('am', ' AM').gsub('pm', ' PM')
      class_date = @class_date
      room_location = course_data.css('.studio').text

      binding.pry
      Course.first_or_create()
     
    end
  end
end





binding.pry


#!!! ALL OCCURS WITHIN THE LOOP OF AN INDIVIDUAL CLASS

#check if course exists
#if yes
  #grab course ID
#if no
 #gym.courses.create(title: "text", description: "text", level: "text", categories: "array",  members_only: "boolean", paid: "boolean")#end
#set course_id

#check if instructor exists
#if yes
  #grab ID
#If no
  #Instructor.create(first_name: "text", last_name: "text", description: "text", cerifications: [], accomplishments: [], philosophy: "text", gender: "text", birthday: "date", email: "text", phone_number: "text", address: "text", city: "text", state: "text", zip_code: "text", raw_description: "text", personal_trainer: "boolean", substitute: "boolean")
#end
#set instructor_id


#create section
#unique to date, course_id, start_time, instructor
#if section exists, log
#else 
  #Section.create(class_date: "DATE", start_time: "TIME", end_time: "TIME", duration: "float", room_location: "text", course_id: "course_id_set_above", instructor_id: "instructor_id_set_above")
#end

#!!! ALL OCCURS WITHIN THE LOOP OF AN INDIVIDUAL CLASS


# @weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']