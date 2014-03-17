require_relative '../db_connect.rb'

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Sports Club LA")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  browser.goto gym["course_url"]
  @week.each do |day|
    @day_of_class = browser.div(css: "##{day}").div(css: '.dayname').span.text.gsub('(','').gsub(')','') + '/' + Time.now.year.to_s
    browser.div(css: "##{day}").divs(css: '.class').each do |course|
      course_data = Nokogiri::HTML(course.html)
      binding.pry
      #course
      title = course_data.css('.name').text.gsub('*', '')
      paid_class = course_data.css('.name').text.include?('**') ? TRUE : FALSE
      class_location = course_data.css('.studio').text
      categories = course_data.css('div')[0].attributes["class"].value.split
      
      #description = #click for description

      #instructor
      instructor = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','')
      personal_trainer = course_data.css('.instructor').text.include?('*') ? TRUE : FALSE
      substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE
      #description = #click for description

      #session
      start_time = course_data.css('.time').text.split[0].gsub('am', ' AM').gsub('pm', ' PM')
      end_time = course_data.css('.time').text.split[2].gsub('am', ' AM').gsub('pm', ' PM')
      level = course_data.css('.level').text + ": " + course_data.css('.level')[0].attributes["title"].text
      day_of_class = @day_of_class


      gym.courses.create(title: "text", duration: "float", description: "text", room_location: "text", level: "text", categories: "array",  members_only: "boolean", paid: "boolean")
    end
  end
end





binding.pry


#!!! ALL OCCURS WITHIN THE LOOP OF AN INDIVIDUAL CLASS

#check if course exists
#if yes
  #grab course ID
#if no
  #gym.courses.create(title: "text", duration: "float", description: "text", room_location: "text", level: "text", members_only: "boolean", paid: "boolean")
#end
#set course_id

#check if instructor exists
#if yes
  #grab ID
#If no
  #Instructor.create(first_name: "text", last_name: "text", description: "text", cerifications: [], accomplishments: [], philosophy: "text", gender: "text", birthday: "date", email: "text", phone_number: "text", address: "text", city: "text", state: "text", zip_code: "text", raw_description: "text")
#end
#set instructor_id


#create section
#unique to date, course_id, start_time, instructor
#if section exists, log
#else 
  #Section.create(class_date: "DATE", start_time: "TIME", end_time: "TIME", course_id: "course_id_set_above", instructor_id: "instructor_id_set_above")
#end

#!!! ALL OCCURS WITHIN THE LOOP OF AN INDIVIDUAL CLASS


# @weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']


# schedule_links.each do |location, link|
#   gym = "SCLA"
#   state = location == "Boston" || "Back Bay" || "Chestnut Hill" ? "MA" : "CA"
#   doc = Nokogiri::HTML(open(link))
#   month = doc.css('#top').css('h2').text.split[6]
#   year = doc.css('#top').css('h2').text.split[8].gsub('‹','')
#   @weekdays.each do |day|
#     number_of_classes = doc.css("##{day}").css('.class').length
#     date = doc.css("##{day}").css('.dayname').css('span').text.gsub('(','').gsub(')','') + "/#{year}"
#     class_counter = 0
#     number_of_classes.times do
#       begin
#         
        
        
#         class_description = Nokogiri::HTML(open(doc.css("##{day}").css('.class')[class_counter].css('.instructor').css('a').attr('href').value)).css('#content').css('p').text
#         instructor_description = Nokogiri::HTML(open(doc.css("##{day}").css('.class')[class_counter].css('.name').css('a').attr('href').value)).css('#content').css('p').text
   

#         #create log to know many successful pulls and how many failures
#         csv_array = [] 
#         csv_array << title << gym << location << state << class_description << instructor << instructor_description << personal_trainer << substitute << month << year << day << start_time << end_time << date << level << class_location << paid_class
#         CSV.open('scla_classes.csv', 'ab') do |csv|
#           csv << csv_array
#         end
#       rescue
#       end
#       class_counter += 1
#     end
#     #create log to record successful versus unsuccessful pulls

#   end  
# end
