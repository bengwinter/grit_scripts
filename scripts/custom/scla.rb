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

org = Organization.where(name: "Sports Club LA")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  browser.goto gym["course_url"]
  sleep(5.0)
  @week.each do |day|
    @year = Time.now.year
    @month = browser.div(css: "##{day}").div(css: '.dayname').span.text.gsub('(','').gsub(')','').split('/')[0].to_i
    @day = browser.div(css: "##{day}").div(css: '.dayname').span.text.gsub('(','').gsub(')','').split('/')[1].to_i
    browser.div(css: "##{day}").divs(css: '.class').each do |course|
      begin
        course_data = Nokogiri::HTML(course.html)

        ##course
        title = course_data.css('.name').text.gsub('*', '')
        level = course_data.css('.level').text + ": " + course_data.css('.level')[0].attributes["title"].text

        if gym.courses.where(title: title, level: level) == []
          paid = course_data.css('.name').text.include?('**') ? TRUE : FALSE
          categories = course_data.css('div')[0].attributes["class"].value.split
          members_only = TRUE ##no website identifier, assuming members only
          description = Nokogiri::HTML(open(course_data.css('a').attr('href').value)).css('#content').css('p').text
          signup = FALSE ##no website identifier, assuming sign up not needed
          size = 0 ##no website identifier

          @course = gym.courses.create(title: title, level: level, description: description, categories: categories, members_only: members_only, paid: paid, signup: signup, size: size)
          @course_creations += 1
          sleep(0.7)
        else 
          @course = gym.courses.where(title: title, level: level).first
          @course_duplications += 1
        end
      rescue
        @course_errors += 1
      end

      ##instructor
      begin
        first_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[0]
        last_name = course_data.css('.instructor').text.gsub('*', '').gsub('Sub: ','').split[1]
        phone_number = "SCLA" #no number provided

        if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
          personal_trainer = course_data.css('.instructor').text.include?('*') ? TRUE : FALSE
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
          raw_description = Nokogiri::HTML(open(course_data.css('.name').css('a').attr('href').value)).css('#content').css('p').text
          description = raw_description
          
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

      ##section
      begin
        start_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[0].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
        end_time = Time.new(@year, @month, @day, course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[0], course_data.css('.time').text.split[2].gsub('am','').gsub('pm','').split(':')[1], 0, gym.timezone_offset)
        duration = (end_time - start_time) / 60
        class_date = Date.new(@year, @month, @day)
        substitute = course_data.css('.instructor').text.include?('Sub') ? TRUE : FALSE

        room_location = course_data.css('.studio').text
     
        if @course.sections.where(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id) == []
          @course.sections.create(class_date: class_date, start_time: start_time, end_time: end_time, instructor_id: @instructor.id, room_location: room_location, duration: duration, substitute: substitute)
          @section_creations += 1
        else
          @section_duplications += 1
        end
      rescue
        @section_errors += 1
      end
     
    end
  end
  File.open('/Users/benwinter/Code/Shelton/production_code/data_collection/logs/scla_logs.txt', 'ab') {|file| file.puts("#{gym.name}(#{gym.id}) at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}")}
end


