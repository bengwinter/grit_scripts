require_relative '../db_connect.rb'

#calendar changes on Sunday or Monday

@course_creations = 0
@course_duplications = 0
@course_errors = 0
@instructor_creations = 0
@instructor_duplications = 0
@instructor_errors = 0
@section_creations = 0
@section_duplications = 0
@section_errors = 0

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Healthworks Fitness Centers for Women")[0]
browser = Watir::Browser.new :firefox

org.gyms.each do |gym|
  browser.goto gym["course_url"]
  sleep (8.0)
  browser.iframe.trs.each do |row|
    data = Nokogiri::HTML(row.html)

    if data.css('.hc_date')[0] != nil
      @year = Time.now.year
      @month = Date::MONTHNAMES.index(data.css('.hc_date')[0].text.split(" ")[0])
      @day = data.css('.hc_date')[0].text.split(" ")[1].to_i
    else
      begin
        ##course
        title = data.css('.classname').text.strip
        level = "Not Provided"

        if gym.courses.where(title: title, level: level) == []
          paid = "Not Provided"
          categories = data.css('.visit_type').css('span').text.strip
          members_only = TRUE ##no website identifier, assuming members only
          sign_up = data.css('.signup_now').length != 0 ? TRUE : FALSE
          size = 0 ##no website identifier
          
          course_popup = Watir::Browser.new :firefox
          course_popup.goto data.css('.classname').css('a')[0].attr('data-url')
          binding.pry
          course_popup.close

          @course = gym.courses.create(title: title, level: level, description: description, categories: categories, members_only: members_only, paid: paid)
          @course_creations += 1
          sleep (0.7)
        else 
          @course = gym.courses.where(title: title, level: level).first
          @course_duplications += 1
        end
      rescue
        @course_errors += 1
      end


      binding.pry
      #instructor
      begin
        first_name = data.css('.trainer')[1].text.split(' ')[0]
        last_name = data.css('.trainer')[1].text.split(' ')[1]
        phone_number = "Healthworks Fitness Centers for Women" #no number provided

        if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
          personal_trainer = TRUE ##not provided so assuming all teachers are available for personal training

          instructor_popup = Watir::Browser.new :firefox
          instructor_popup.goto data.css('.classname').css('a')[0].attr('data-url')
            binding.pry
            cerifications = ""
            accomplishments = ""
            philosophy = ""
            gender = "Not Provided"
            birthday = "Not Provided"
            email = "Not Provided"
            address = "Not Provided"
            city = "Not Provided"
            state = "Not Provided"
            zip_code = "Not Provided"
            raw_description = ""
            description = raw_description
          instructor_popup.close
            
          
          @instructor = Instructor.create(first_name: first_name, last_name: last_name, phone_number: phone_number, personal_trainer: personal_trainer, cerifications: cerifications, accomplishments: accomplishments, philosophy: philosophy, gender: gender, birthday: birthday, email: email, address: address, city: city, state: state, zip_code: zip_code, description: description, raw_description: raw_description)
          @instructor_creations += 1
          sleep(1.1)
        else
          @instructor = Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number).first
          @instructor_duplications += 1
        end
      rescue
        @instructor_errors += 1
      end
    
    end

    

  end
end

#   @week.each do |day|
    
#     browser.div(css: "##{day}").divs(css: '.class').each do |course|
#       

#      

#       ##section
#       begin
#         start_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
#         end_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
#         duration = (end_time - start_time) / 60
#         class_date = Date.new(@year, @month, @day)
#         substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE

#         room_location = course_data.css('.studio').text
     
#         if @course.sections.where(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id) == []
#           @course.sections.create(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id, room_location: room_location, duration: duration, substitute: substitute)
#           @section_creations += 1
#         else
#           @section_duplications += 1
#         end
#       rescue
#         @section_errors += 1
#       end
     
#     end
#   end
#   File.open('/Users/benwinter/Code/Shelton/production_code/data_collection/logs/scla_logs.txt', 'ab') {|file| file.puts("#{gym} at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}")}
# end


# @all_class_details = []
# browser.frame.elements(css: '.evenRow').each do |x|
#   @all_class_details << Nokogiri::HTML.parse(x.html).css('td')
# end

# browser.frame.elements(css: '.oddRow').each do |x|
#   @all_class_details << Nokogiri::HTML.parse(x.html).css('td')
# end

# @all_instructor_descriptions = []
# browser.frame.elements(css: '.modalBio').each do |bio|
#   bio.click
#   bio_hash = {}
#   sleep(1.0)
#   bio_hash["#{bio.text}"] = Nokogiri::HTML(browser.frame.when_present.div(class: 'bio').html)
#   @all_instructor_descriptions << bio_hash
# end


# @all_class_descriptions = []
# browser.frame.elements(css: '.modalClassDesc').each do |description|
#   description.click
#   description_hash = {}
#   sleep (1.0)
#   description_hash["#{description.text}"] = Nokogiri::HTML(browser.frame.when_present.div(class: 'classDescription').html).css('div').children[1].text
#   @all_class_descriptions << description_hash 
# end



# @all_class_details.each do |y|
#   start_time = y[0].text
#   duration = y[6].text
#   #end_time = some function of start time and duration
#   title = y[2].text
#   class_location = y[5].text
#   instructor_name_short = y[3].text
#   gym_location = y[4].text
# end

