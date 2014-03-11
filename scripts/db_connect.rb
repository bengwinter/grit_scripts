require 'rubygems'
require 'nokogiri'
require 'watir'
require 'watir-webdriver'
require 'pg'
require 'pry'
require 'active_record'
require 'json'
require 'date'
require 'open-uri'

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "localhost",
  :port     => 5432,
  :database => "gritsy_development"
)

class Organization < ActiveRecord::Base
  has_many :gyms
end

class Gym < ActiveRecord::Base
  belongs_to :organization
  has_many :courses
  has_many :instructors, through: :courses
end

class User < ActiveRecord::Base
  has_many :appointments
end

class Instructor < ActiveRecord::Base
  has_many :courses
  has_many :gyms, through: :courses
end

class Course < ActiveRecord::Base
  belongs_to :gym
  belongs_to :instructor
  has_many :sections
end

class Appointment < ActiveRecord::Base
  belongs_to :section
  belongs_to :user
end

class Section < ActiveRecord::Base
  belongs_to :course
  has_many :appointments
end


#take raw_results files (which will all be )