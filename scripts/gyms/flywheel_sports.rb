require_relative '../db_connect.rb'

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Flywheel Sports")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  @course_creations = 0
  @course_duplications = 0
  @course_errors = 0
  @instructor_creations = 0
  @instructor_duplications = 0
  @instructor_errors = 0
  @section_creations = 0
  @section_duplications = 0
  @section_errors = 0
  @section_cancellations = 0
  
  gym["course_url"].each do |course_url|
    browser.goto course_url

    sleep (4.2)
    browser.divs(css: '.column').each do |day|
      
      @year = Time.now.year
      @month = day.span(css: '.day').text.split[1].split('/')[0].to_i
      @day = day.span(css: '.day').text.split[1].split('/')[1].to_i
            
      data = Nokogiri::HTML(day.html)
      data.css('a').each do |session|

      ##course
        begin
          title = session.css('.type').text != "" ? session.css('.type').text.split(' (')[0].strip : session.css('.music').text.split(' (')[0].gsub('(1 Hour)','').strip
          level = "Not Provided"

          if gym.courses.where(title: title, level: level) == []
            paid = TRUE
            categories = ["Cycling"]
            members_only = FALSE ##no website identifier, assuming anyone can sign up
            
            description = "Not Provided"


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

      #instructor
        begin
          first_name = session.css('span').text.split[0].strip
          last_name = session.css('span').text.split[1].strip
          phone_number = "Flywheel Sports" #no number provided

          if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
            personal_trainer = FALSE ##not provided so assuming all teachers are not available for personal training
            cerifications = "Not Provided"
            accomplishments = "Not Provided"
            philosophy = "Not Provided"
            gender = "Not Provided"
            birthday = "Not Provided"
            email = "Not Provided"
            address = "Not Provided"
            city = "Not Provided"
            state = "Not Provided"
            zip_code = "Not Provided"
            raw_description = "Update Needed"
            description = "Update Needed"
              
            
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
        
      #section
        begin
          if (session.css('.time').text.include?('pm') && session.css('.time').text.gsub('am','').gsub('pm','').strip.split(':')[0].to_i != 12)
            start_time_utc = Time.new(@year, @month, @day, (session.css('.time').text.gsub('am','').gsub('pm','').strip.split(':')[0].to_i + 12), session.css('.time').text.gsub('am','').gsub('pm','').strip.split(':')[1], 0, gym.timezone_offset)
          else
            start_time_utc = Time.new(@year, @month, @day, session.css('.time').text.gsub('am','').gsub('pm','').strip.split(':')[0], session.css('.time').text.gsub('am','').gsub('pm','').strip.split(':')[1], 0, gym.timezone_offset)
          end
          end_time_utc = session.css('.music').text != "" ? start_time_utc + 60.minutes : start_time_utc + title.split[1].to_i.minutes
          start_time_local = start_time_utc + gym.timezone_offset.to_i.hours
          end_time_local = end_time_utc + gym.timezone_offset.to_i.hours
          duration = (end_time_utc - start_time_utc) / 60
          class_date = Date.new(@year, @month, @day)
          substitute = FALSE
          room_location = "Not Provided"
          signup = TRUE
          size = 55 #based off of number of bikes available for reservation
       
          if @course.sections.where(class_date: class_date, start_time_utc: start_time_utc, end_time_utc: end_time_utc, instructor_id: @instructor.id) == []
            @course.sections.create(class_date: class_date, start_time_utc: start_time_utc, end_time_utc: end_time_utc, start_time_local: start_time_local, end_time_local: end_time_local, instructor_id: @instructor.id, room_location: room_location, duration: duration, substitute: substitute, signup: signup, size: size)
            @section_creations += 1
          else
            @section_duplications += 1
          end
        rescue
          @section_errors += 1
        end
       
      end
    end
    File.open('/Users/benwinter/Code/Gritsy/production_code/data_collection/logs/flywheel_sports_logs.txt', 'ab') {|file| file.puts("#{gym.name}(#{gym.id}) at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}, Section Cancellation: #{@section_cancellations}")}
  end
end