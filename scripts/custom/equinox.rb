require_relative '../db_connect.rb'

@course_creations = 0
@course_duplications = 0
@course_errors = 0
@instructor_creations = 0
@instructor_duplications = 0
@instructor_errors = 0
@section_creations = 0
@section_duplications = 0
@section_errors = 0

 # start_date = Date.today # your start
 # end_date = Date.today + 1.year # your end
 # my_days = [1,2,3] # day of the week in 0-6. Sunday is day-of-week 0; Saturday is day-of-week 6.
 # result = (start_date..end_date).to_a.select {|k| my_days.include?(k.wday)}

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
org = Organization.where(name: "Equinox")[0]
browser = Watir::Browser.new :firefox

org.gyms.each do |gym|
  browser.goto gym["course_url"]

  #collect categories for courses
  # @course_categories = {}

  # @category_key = {}
  # @category_key["1"] = "cardio"
  # @category_key["3"] = "conditioning"
  # @category_key["110"] = "conscious_movement"
  # @category_key["2"] = "martial_arts"
  # @category_key["4"] = "mind_body"
  # @category_key["105"] = "pilates"
  # @category_key["6"] = "studio_cycling"
  # @category_key["104"] = "yoga"
  
  # @categories = ["1", "3", "110", "2", "4", "105", "6", "104"]
  
  # @categories.each do |category|
  #   browser.select_list(:id, "ClassCategoryId").select_value(category)
  #     #do a nokogiri scrape of the whole page, grab the titles and mark down which category scrape was each and then at the end create a categories array for each course title based upon when they appeared on screen
  #      doc = Nokogiri::HTML(open(broswer.divs(css: '.class-detail').html))
  # end
  
  browser.select_list(:id, "ClassCategoryId").select_value("1")

  binding.pry
  browser.goto gym["course_url"]
  #always scrape on Sunday for Following week so set first day equal ot the mondya after Time.now.day

  broswer.divs(css: '.class-detail').each do |block|
    @day_counter = 0
    block.lis.each do |course|
      @day_of_week = @week[day_counter % 7]
      title = ""
      level = ""
      description = ""
      categories = ""
      members_only = TRUE
      paid = FALSE


      gym.courses.create(title: title, level: level, description: description, categories: categories, members_only: members_only, paid: paid)

    end
    @day_counter += 1
  end
end


#   binding.pry
  
#   browser.div(css: "##{day}").divs(css: '.class').each do |course|
#       begin
#         course_data = Nokogiri::HTML(course.html)

#         #course
#         title = course_data.css('.name').text.gsub('*', '')
#         level = course_data.css('.level').text + ": " + course_data.css('.level')[0].attributes["title"].text

#         if gym.courses.where(title: title, level: level) == []
#           paid = course_data.css('.name').text.include?('**') ? TRUE : FALSE
#           categories = course_data.css('div')[0].attributes["class"].value.split
#           members_only = TRUE
#           description = Nokogiri::HTML(open(course_data.css('a').attr('href').value)).css('#content').css('p').text
#           sleep (0.7)

#           @course = 
#           @course_creations += 1
#         else 
#           @course = gym.courses.where(title: title, level: level).first
#           @course_duplications += 1
#         end
#       rescue
#         @course_errors += 1
#       end

#       #instructor
#       begin
#         first_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[0]
#         last_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[1]
#         phone_number = "SCLA"

#         if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
#           personal_trainer = course_data.css('.instructor').text.include?('*') ? TRUE : FALSE
#           substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE
#           cerifications = []
#           accomplishments = []
#           philosophy = "Not Provided"
#           gender = "Not Provided"
#           birthday = "Not Provided"
#           email = "Not Provided"
#           address = "Not Provided"
#           city = "Not Provided"
#           state = "Not Provided"
#           zip_code = "Not Provided"
#           raw_description = Nokogiri::HTML(open(course_data.css('.name').css('a').attr('href').value)).css('#content').css('p').text
#           description = raw_description
#           sleep(1.1)
#           @instructor = Instructor.create(first_name: first_name, last_name: last_name, phone_number: phone_number, personal_trainer: personal_trainer, substitute: substitute, cerifications: cerifications, accomplishments: accomplishments, philosophy: philosophy, gender: gender, birthday: birthday, email: email, address: address, city: city, state: state, zip_code: zip_code, description: description, raw_description: raw_description)
#           @instructor_creations += 1
#         else
#           @instructor = Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number).first
#           @instructor_duplications += 1
          
#         end
#       rescue
#         @instructor_errors += 1
#       end

#       #section
#       begin
#         start_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
#         end_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
#         duration = (end_time - start_time) / 60
#         class_date = Date.new(@year, @month, @day)
#         room_location = course_data.css('.studio').text
     
#         if @course.sections.where(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id) == []
#           @course.sections.create(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id, room_location: room_location, duration: duration)
#           @section_creations += 1
#         else
#           @section_duplications += 1
#         end
#       rescue
#         binding.pry
#         @section_errors += 1
#       end
     
#   end
# end


# File.open('/Users/benwinter/Code/Shelton/production_code/data_collection/logs/equinox_logs.txt', 'ab') {|file| file.puts("#{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}")}