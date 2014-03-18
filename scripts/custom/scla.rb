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

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Sports Club LA")[0]
browser = Watir::Browser.new :firefox

org.gyms.each do |gym|
  browser.goto gym["course_url"]
  @week.each do |day|
    @class_date = browser.div(css: "##{day}").div(css: '.dayname').span.text.gsub('(','').gsub(')','') + '/' + Time.now.year.to_s
    browser.div(css: "##{day}").divs(css: '.class').each do |course|
      begin
        course_data = Nokogiri::HTML(course.html)

        #course
        title = course_data.css('.name').text.gsub('*', '')
        level = course_data.css('.level').text + ": " + course_data.css('.level')[0].attributes["title"].text

        if gym.courses.where(title: title, level: level) == []
          paid = course_data.css('.name').text.include?('**') ? TRUE : FALSE
          categories = course_data.css('div')[0].attributes["class"].value.split
          members_only = TRUE  
          course.links[0].click
          description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
          sleep(1.4)
          browser.div(css: '.infobox_close').click

          course = gym.courses.create(title: title, level: level, description: description, categories: categories, members_only: members_only, paid: paid)
          @course_creations += 1
        else 
          course = gym.courses.where(title: title, level: level).first
          @course_duplications += 1
        end
      rescue
        @course_errors += 1
      end

      #instructor
      begin
        first_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[0]
        last_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[1]
        phone_number = "SCLA"

        if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
          personal_trainer = course_data.css('.instructor').text.include?('*') ? TRUE : FALSE
          substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE
          cerifications = []
          accomplishments = []
          philosophy = "Not Provided"
          gender = "Not Provided"
          birthday = "Not Provided"
          email = "Not Provided"
          address = "Not Provided"
          city = "Not Provided"
          state = "Not Provided"
          zip_code = "Not Provided"

          course.links[1].click
          description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
          raw_description = browser.div(css: '.infobox_content').p.html.gsub('<p>','').gsub('</p>','').strip
          sleep(1.1)
          browser.div(css: '.infobox_close').click

          instructor = Instructor.create(first_name: first_name, last_name: last_name, phone_number: phone_number, personal_trainer: personal_trainer, substitute: substitute, cerifications: cerifications, accomplishments: accomplishments, philosophy: philosophy, gender: gender, birthday: birthday, email: email, address: address, city: city, state: state, zip_code: zip_code, description: description, raw_description: raw_description)
          @instructor_creations += 1
        else
          instructor = Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number).first
          @instructor_duplications += 1
        end
      rescue
        @instructor_errors += 1
      end

#validates_uniqueness_of :course_id, scope: [:day_of_class, :start_time, :end_time,, :instructor_id]

      #section
      begin
        start_time = course_data.css('.time').text.split[0].gsub('am', ' AM').gsub('pm', ' PM')
        end_time = course_data.css('.time').text.split[2].gsub('am', ' AM').gsub('pm', ' PM')
        duration = ""
        class_date = @class_date
        room_location = course_data.css('.studio').text
        if course.sections.where(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: instructor.id) == []
          course.sections.create(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: instructor.id, room_location: room_location, duration: duration)
          @section_creations += 1
        else
          @section_duplications += 1
        end
      rescue
        @section_errors += 1
      end
     
    end
  end
end


File.open('/Users/benwinter/Code/Shelton/production_code/data_collection/logs/scla_logs.txt', 'ab') {|file| file.puts("#{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}")}