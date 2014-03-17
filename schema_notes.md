Relationships

Organization 
Example: Equinox
has many Gyms

Gym
Example: Equinox Back Bay
belongs to Organization
has many Courses

Course 
Example: Bikram
belongs to Gym
has many Sections

Instructor
Example: Jillian Michaels
has many Sections

Section
Example: Bikram, Monday at 7:00 AM with Jillian Michaels
belongs to Course
belongs to Instructor
has many Appointments

User
Example: Anyone who works out or goes to a gym
has many Appointments

Appointments
Example: User attends Bikram, Monday at 7:00 AM with Jillian Michaels
belongs to User
belongs to Section

Appointment
    rating (integer)
    review (text)
    user_id (integer); belongs to user
    section_id (integer); belongs to section

Course
    title (text)
    duration (float)
    description (text)
    room_location (text)
    level (text)
    categories (text), array 
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
    mbo_url (text)
    private_training (integer) (1=yes, 2=no, 3=only private training)
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