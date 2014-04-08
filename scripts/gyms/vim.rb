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

org = Organization.where(name: "VIM Fitness Spa & Salon")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  gym["course_url"].each do |course_url|
    if course_url != ""
      browser.goto course_url

      if gym.address == "350 Massachusetts Avenue"
        click_tag = "2"
      else
        click_tag = "3"
      end

      sleep(3.4)

      browser.frame.td(css: '#tabTD107').click
      browser.frame.link(css: '.selectBox-dropdown').click
      browser.frame.link(rel: click_tag).click

      sleep(6.2)

      browser.frame.div(css: '#main-content').table(css: '#classSchedule-mainTable').trs.each do |row|
        data = Nokogiri::HTML(row.html)

        if data.css('.evenRow')[0] == nil && data.css('.oddRow')[0] == nil
          @year = Time.now.year
          @month = Date::MONTHNAMES.index(data.css('b').children[2].text.split(' ')[0])
          @day = data.css('b').children[2].text.split(' ')[1].to_i
        else
        ##course
          begin 
            title = data.css('td')[2].text.strip
            level = "Not Provided"

            if gym.courses.where(title: title, level: level) == []
              paid = "Not Provided"
              categories = "Not Provided"
              members_only = TRUE ##no website identifier, assuming members only
              
              sleep(1.2)
              row.tds[2].link.click
                description = browser.frame.div(css: '#descDivWrapper').div(css: '.userHTML').text
              browser.frame.div(css: '#removeModal').click

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
            first_name = data.css('td')[3].text.split(' ')[0].strip
            last_name = data.css('td')[3].text.split(' ')[1] == nil ? "VIM" : data.css('td')[3].text.split(' ')[1].strip
            phone_number = "VIM Fitness Spa & Salon" #no number provided

            if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
              personal_trainer = TRUE ##not provided so assuming all teachers are available for personal training
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
              raw_description = "Not Provided"
              description = "Not Provided"
                
              
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
             if (data.css('td')[0].text.include?('pm') && data.css('td')[0].text.gsub(' ','').gsub('am','').gsub('pm','').strip.split(':')[0].to_i != 12) 
              start_time_utc = Time.new(@year, @month, @day, (data.css('td')[0].text.gsub(' ','').gsub('am','').gsub('pm','').strip.split(':')[0].to_i + 12), data.css('td')[0].text.gsub(' ','').gsub('am','').gsub('pm','').strip.split(':')[1].to_i, 0, gym.timezone_offset)
            else
              start_time_utc = Time.new(@year, @month, @day, data.css('td')[0].text.gsub(' ','').gsub('am','').gsub('pm','').strip.split(':')[0].to_i, data.css('td')[0].text.gsub(' ','').gsub('am','').gsub('pm','').strip.split(':')[1].to_i, 0, gym.timezone_offset)            
            end
            
            raw_duration = data.css('td')[5].text.split(' ')
            if raw_duration[2].include?('hour')
              duration = raw_duration[1].to_i * 60
            else
              duration = raw_duration[1].to_i
            end

            end_time_utc = start_time_utc + duration.minutes

            start_time_local = start_time_utc + gym.timezone_offset.to_i.hours
            end_time_local = end_time_utc + gym.timezone_offset.to_i.hours

            class_date = Date.new(@year, @month, @day)
            substitute = FALSE #not provided
            room_location = "Not Provided"
            signup = FALSE #not provided
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
      File.open('/Users/benwinter/Code/Gritsy/production_code/data_collection/logs/vim_logs.txt', 'ab') {|file| file.puts("#{gym.name}(#{gym.id}) at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}, Section Cancellation: #{@section_cancellations}")}
    else
    end
  end
end