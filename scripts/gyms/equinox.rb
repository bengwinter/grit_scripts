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

@week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
org = Organization.where(name: "Equinox")[0]
browser = Watir::Browser.new :phantomjs

org.gyms.each do |gym|
  gym["course_url"].each do |course_url|
    if course_url != ""
      sleep(4.2)
      browser.goto course_url

      ##collect course categories
      @category_by_courses = {}

      @category_key = {}
      @category_key["1"] = "cardio"
      @category_key["2"] = "martial_arts"
      @category_key["3"] = "conditioning"
      @category_key["4"] = "mind_body"
      @category_key["5"] = "pool_programs"
      @category_key["6"] = "studio_cycling"
      @category_key["104"] = "yoga"
      @category_key["105"] = "pilates"
      @category_key["106"] = "dance"
      @category_key["110"] = "conscious_movement"
      
      @category_key.each do |category_id, category_name|
        begin
          browser.select_list(:id, "ClassCategoryId").select_value(category_id)
          sleep(2.2)
          schedule = Nokogiri::HTML(browser.table(css: '.class-schedule').html)
          schedule.css('.class-detail').css('a').each do |course|
            class_title = course.children.text.gsub('*','').strip
            if @category_by_courses["#{class_title}"] != nil
              @category_by_courses["#{class_title}"] << category_name
              @category_by_courses["#{class_title}"].uniq!
            else 
              @category_by_courses["#{class_title}"] = []
              @category_by_courses["#{class_title}"] << category_name
            end
          end
        rescue
        end
      end

      browser.goto course_url
      browser.as(class: 'btn-close')[0].click
      
      @day_counter = 0
      today = Date.today
      next_monday = today += 1 + ((0 - today.wday) % 7)
      @dates = []
      3.times do
        @dates << next_monday << (next_monday + 1) << (next_monday + 2) << (next_monday + 3) << (next_monday + 4) << (next_monday + 5) << (next_monday + 6)
      end

      browser.elements(css: 'td.class-detail').each do |x|
        @year = @dates[@day_counter].year
        @month = @dates[@day_counter].month
        @day = @dates[@day_counter].day

        x.lis.each do |li|
          course_data = Nokogiri::HTML(li.html).css("li")
          
        ##course
          begin
            title = course_data.children[0].text.gsub('*','').strip
            level = "No Level" ##no website identifier for levels
              if gym.courses.where(title: title, level: level) == []
                paid = FALSE ##no website identifier for payment
                categories = @category_by_courses["#{title}"]
                members_only = TRUE ##no website identifier, assuming members only
                
                ##grabbing values from pop up including the instructor
                li.a.click
                  raw_class_description = Nokogiri::HTML.parse(browser.divs(class: "about-copy")[1].html)
                  class_description = raw_class_description.css('p').text
                  @raw_instructor_description = Nokogiri::HTML.parse(browser.divs(class: "about-copy")[2].html).css('p').text

                browser.div(css: '.overlay').link(css: '.overlayclose').click
                
                @course = gym.courses.create(title: title, level: level, description: class_description, categories: categories, members_only: members_only, paid: paid)
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
            first_name = course_data.children[2].text.split[0].strip
            last_name = course_data.children[2].text.split[1].strip
            phone_number = "Equinox" ##no number provided

            if Instructor.where(first_name: first_name, last_name: last_name, phone_number: phone_number) == []
              personal_trainer = TRUE ##not provided so assuming all teachers are available for personal training
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
              instructor_description = ""

              @instructor = Instructor.create(first_name: first_name, last_name: last_name, phone_number: phone_number, personal_trainer: personal_trainer, cerifications: cerifications, accomplishments: accomplishments, philosophy: philosophy, gender: gender, birthday: birthday, email: email, address: address, city: city, state: state, zip_code: zip_code, description: instructor_description, raw_description: @raw_instructor_description)
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
            binding.pry
            if (@day_counter <= 6 && course_data.children[4].text.split('-')[0].split(':')[0].to_i != 12)
              start_time_utc = Time.new(@year, @month, @day, (course_data.children[4].text.split('-')[0].split(':')[0].to_i + 12), course_data.children[4].text.split('-')[0].split(':')[1], 0, gym.timezone_offset)
              end_time_utc = Time.new(@year, @month, @day, (course_data.children[4].text.split('-')[1].split(':')[0].to_i + 12), course_data.children[4].text.split('-')[1].split(':')[1], 0, gym.timezone_offset)
            else
              start_time_utc = Time.new(@year, @month, @day, course_data.children[4].text.split('-')[0].split(':')[0], course_data.children[4].text.split('-')[0].split(':')[1], 0, gym.timezone_offset)
              end_time_utc = Time.new(@year, @month, @day, course_data.children[4].text.split('-')[1].split(':')[0], course_data.children[4].text.split('-')[1].split(':')[1], 0, gym.timezone_offset)
            end
            start_time_local = start_time_utc + gym.timezone_offset.to_i.hours
            end_time_local = end_time_utc + gym.timezone_offset.to_i.hours
            duration = (end_time_utc - start_time_utc) / 60
            class_date = Date.new(@year, @month, @day)
            signup = FALSE ##no website identifier, assuming sign up not needed
            size = 0 ##no website identifier
            room_location = "Not Provided"
            substitute = course_data.children[2].text.include?('(SUB)') ? TRUE : FALSE

            ##may need something here to not create classes that are for days in months that are not in current month. need to see how/when equinox changes their schedule
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
        @day_counter += 1
      end
      File.open('/Users/benwinter/Code/Gritsy/production_code/data_collection/logs/equinox_logs.txt', 'ab') {|file| file.puts("#{gym.name}(#{gym.id}) at #{Time.now}; Course Creations: #{@course_creations}, Course Duplications: #{@course_duplications}, Course Errors: #{@course_errors}, Instructor Creations: #{@instructor_creations}, Instructor Duplications: #{@instructor_duplications}, Instructor Errors: #{@instructor_errors}, Section Creations: #{@section_creations}, Section Duplications: #{@section_duplications}, Section Errors: #{@section_errors}, Section Cancellation: #{@section_cancellations}")}
    else
    end
  end
end