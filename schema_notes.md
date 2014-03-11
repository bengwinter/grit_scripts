Relationships

Organization
has_many :gyms

Gym
belongs_to :organization
has_many :courses
has_many :instructors, through: :courses

Course
belongs_to :gym
has_many :sections

Section
belongs_to :course
belongs_to :instructor
has_many :appointments

Instructor
has_many :courses
has_many :gyms, through: :courses


User
has_many :appointments

Appointment
belongs_to :section
belongs_to :user


Appointment
    notes (text); placeholder
    user_id (integer); belongs to user
    section_id (integer); belongs to section

Course
    title (text)
    duration (float)
    description (text)
    room_location (text)
    level (text)
    members_only (boolean)
    paid (boolean)
    gym_id (integer); belongs to gym


Gym
    name (text)
    location (text)
    address (text)
    city (text)
    state (text)
    zip_code (text)
    phone_number (text)
    hours (text), array, [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday] respectively
    url (text)
    course_url (text)
    mbo_id (integer)
    scrape_freq (integer)
    organization_id (integer); belongs to organization

Instructor
    first_name (text)
    last_name (text)
    description (text)
    cerifications (text), array
    accomplishments (text), array
    philosophy (text)
    gender (text)
    birthday (date)
    email (text)
    phone_number (text)
    address (text)
    city (text)
    state (text)
    zip_code (text)
    raw_description (text)

Organzation
    name (text)
    geo_footprint (text), 1 = national, 2 = regional, 3 = local
    web_provider (text)
    number_locations (integer)
    mbo_id (integer)
    url (text)

Section
    class_date (date)
    start_time (time)
    end_time (time)
    instructor_id (integer); belongs to instructor
    course_id (integer); belongs to course

User
    first_name (text)
    last_name (text)
    gender (text)
    birthday (date)
    email (text)
    phone_number (text)
    address (text)
    city (text)
    state (text)
    zip_code (text)
    gym_memberships (text), array
    height (integer)
    weight (integer)