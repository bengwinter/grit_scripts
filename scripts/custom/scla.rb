require_relative '../db_connect.rb'

binding.pry

gym = Organization.where(name: "Sports Club LA")


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





# schedule_links = {"Boston" => "http://schedules.sportsclubla.com/?club=1", "Chestnut Hill" => "http://schedules.sportsclubla.com/?club=7", "San Francisco" => "http://schedules.sportsclubla.com/?club=5"}

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
#         title = doc.css("##{day}").css('.class')[class_counter].css('.name').text.gsub('*', '')
#         paid_class = doc.css("##{day}").css('.class')[class_counter].css('.name').text.include?('**') ? TRUE : FALSE
#         class_location = doc.css("##{day}").css('.class')[class_counter].css('.studio').text
#         instructor = doc.css("##{day}").css('.class')[class_counter].css('.instructor').text.gsub('*', '').gsub('Sub: ','')
#         personal_trainer = doc.css("##{day}").css('.class')[class_counter].css('.instructor').text.include?('*') ? TRUE : FALSE
#         substitute = doc.css("##{day}").css('.class')[class_counter].css('.instructor').text.include?('Sub') ? TRUE : FALSE
#         start_time = doc.css("##{day}").css('.class')[0].css('.time').text.split[0].gsub('am', ' AM').gsub('pm', ' PM')
#         end_time = doc.css("##{day}").css('.class')[0].css('.time').text.split[2].gsub('am', ' AM').gsub('pm', ' PM')
#         level = doc.css("##{day}").css('.class')[0].css('.level').text
        
        
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
