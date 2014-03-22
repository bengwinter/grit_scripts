require 'rubygems'
require 'nokogiri'
require 'watir'
require 'watir-webdriver'
require 'pg'
require 'pry'
require 'active_record'
require 'json'
require 'date'
require 'chronic'
require 'open-uri'

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :port     => 5432,
  :database => "gritsy_development"
)

class Organization < ActiveRecord::Base
  has_many :gyms
  
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :url
  #uniqueness based on name OR url
end

class Gym < ActiveRecord::Base
  belongs_to :organization
  has_many :courses
  
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :organization_id
  #uniquness based on Address, URL, course-url 
  #raise error if name is the same
end

class User < ActiveRecord::Base
  has_many :appointments
end

class Instructor < ActiveRecord::Base
  has_many :sections

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_uniqueness_of :first_name, scope: [:last_name, :phone_number]
  #uniquness based on first name, last name OR  room_location, level AND duration
end

class Course < ActiveRecord::Base
  belongs_to :gym
  has_many :sections
  
  validates_presence_of :title
  validates_presence_of :level
  validates_uniqueness_of :title, scope: [:level, :gym_id]

end

class Appointment < ActiveRecord::Base
  belongs_to :section
  belongs_to :user
end

class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
  has_many :appointments
  
  #add uniquness for combination of date, start time and end time, should not be any duplicates for the combination of those three
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_presence_of :class_date
  validates_presence_of :room_location
  validates_uniqueness_of :course_id, scope: [:class_date, :start_time, :end_time, :instructor_id]

end

