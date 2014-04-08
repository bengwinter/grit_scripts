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
@section_cancellations = 0

# @week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

org = Organization.where(name: "Cambridge Athletic Club")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  gym["course_url"].each do |course_url|
    if course_url != ""
      browser.goto course_url

      sleep(6.2)

      browser.div(css: '.schedule').trs.each do |row|
        data = Nokogiri::HTML(row.html)

        if data.css('.schedule_header')[0] != nil
          @year = Time.now.year
          @month = Date::MONTHNAMES.index(data.css('.hc_date')[0].text.split(" ")[0])
          @day = data.css('.hc_date')[0].text.split(" ")[1].to_i
        elsif data.css('tr')[0].attributes["class"].value.include?("cancel")
          begin
            c_title = data.css('.classname').text.strip
            c_level = "Not Provided"
            c_start_time_utc = Time.new(@year, @month, @day, data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[0], data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[1], 0, gym.timezone_offset)
            c_end_time_utc = Time.new(@year, @month, @day, data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[0], data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[1], 0, gym.timezone_offset)
            c_class_date = Date.new(@year, @month, @day)

            gym.courses.where(title: c_title, level: c_level)[0].sections.where(class_date: c_class_date, start_time_utc: c_start_time_utc, end_time_utc: c_end_time_utc)[0].destroy
            @section_cancellations += 1
          rescue
          end
        else
        ##course
          begin  
            title = data.css('.classname').text.strip
            level = "Not Provided"

            if gym.courses.where(title: title, level: level) == []
              paid = "Not Provided"
              categories = data.css('.visit_type').css('span').text.strip
              members_only = TRUE ##no website identifier, assuming members only
              
              sleep(1.2)
              course_popup = Watir::Browser.new :phantomjs
              course_popup.goto data.css('.classname').css('a')[0].attr('data-url')
                description = course_popup.div(css: '.class_description').text
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

        ##instructor
          begin
            first_name = data.css('.trainer')[1].text.split(' ')[0]
            last_name = data.css('.trainer')[1].text.split(' ')[1]
            phone_number = "Cambridge Athletic Center" #no number provided

            if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
              personal_trainer = TRUE ##not provided so assuming all teachers are available for personal training
              sleep(0.5)
              instructor_popup = Watir::Browser.new :phantomjs
              instructor_popup.goto data.css('.trainer').css('a')[0].attr('data-url')
                cerifications = "See Raw Description"
                accomplishments = "See Raw Description"
                philosophy = "See Raw Description"
                gender = "Not Provided"
                birthday = "Not Provided"
                email = "Not Provided"
                address = "Not Provided"
                city = "Not Provided"
                state = "Not Provided"
                zip_code = "Not Provided"
                raw_description = instructor_popup.div(css: '.trainer_bio').text
                description = ""
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
          
        #section
          begin
            if (data.css('.hc_starttime').text.include?('PM') && data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[0].to_i != 12) 
              start_time_utc = Time.new(@year, @month, @day, (data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[0].to_i + 12), data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[1], 0, gym.timezone_offset)
            else
              start_time_utc = Time.new(@year, @month, @day, data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[0], data.css('.hc_starttime').text.gsub('AM','').gsub('PM','').strip.split(':')[1], 0, gym.timezone_offset)              
            end
            if (data.css('.hc_endtime').text.include?('PM') && data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').strip.split(':')[0].to_i != 12)
              end_time_utc = Time.new(@year, @month, @day, (data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[0].to_i + 12), data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[1], 0, gym.timezone_offset)
            else 
              end_time_utc = Time.new(@year, @month, @day, data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[0], data.css('.hc_endtime').text.gsub('AM','').gsub('PM','').gsub('-','').strip.split(':')[1], 0, gym.timezone_offset)
            end
            start_time_local = start_time_utc + gym.timezone_offset.to_i.hours
            end_time_local = end_time_utc + gym.timezone_offset.to_i.hours
            duration = (end_time_utc - start_time_utc) / 60
            class_date = Date.new(@year, @month, @day)
            substitute = data.css('.trainer')[1].text.include?('sub') ? TRUE : FALSE
            room_location = "Not Provided"
            signup = data.css('.signup_now').length != 0 ? TRUE : FALSE
            size = 0 ##no website identifier

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
      File.open('/Users/benwinter/Code/Gritsy/production_code/data_collection/logs/cac_logs.txt', 'ab') {|file| file.puts("#{gym.name}(#{gym.id}) at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}, Section Cancellation: #{@section_cancellations}")}
    else
    end
  end
end