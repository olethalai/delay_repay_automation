require 'selenium-webdriver'
require 'yaml'
require 'date'
require "test/unit/assertions"
include Test::Unit::Assertions

user_fields = [
  :title,
  :first_name,
  :last_name,
  :email,
  :phone,
  :house_number,
  :road,
  :town,
  :county,
  :postcode,
  :photocard_id
]

ticket_fields = [
  :type,
  :light_blue_number,
  :dark_blue_number,
  :cost,
  :path_to_ticket_image
]

# File I/O

def make_yaml_template(file, fields)
  fields.each do |field|
    file.puts "#{field}: "
  end
end

def load_config(filename, fields)
  # Load file
  file = nil
  begin
    file = YAML.load_file(filename)
  rescue
    # Create file as template if it does not exist
    puts "#{filename} does not exist; creating template."
    file = File.open(filename, 'w')
    make_yaml_template(file, fields)
    file.close
    # Open file so user can edit it straight away
    puts 'Opening file for editing. Fill in and try again.'
    exec "open #{filename}"
    exit(1)
  end

  # Confirm that all required fields are filled in
  fields.each do |field|
    assert_not_nil(file[field.to_s])
  end

  return file
end

# Form element interactions

def dropdown_select(element, input)
  select_list = Selenium::WebDriver::Support::Select.new(element)
  select_list.select_by(:text, input)
end

def textbox_type(element, input)
  element.send_keys(input)
end

def file_upload(element, input)
  element.send_keys(input)
end

user = load_config('user_config.yml', user_fields)
ticket = load_config('ticket_config.yml', ticket_fields)

# Split up pounds and pence in the ticket cost
ticket['pounds'] = ticket['cost'].floor
ticket['pence'] = (ticket['cost'] * 100 % 100)

# Open the delay repay form
browser = Selenium::WebDriver.for(:firefox)
browser.navigate.to('http://www.thameslinkrailway.com/contact-us/delay-repay/claim-form/')

# Fill in the form
dropdown_select(browser.find_element(:id, 'nametitle'), user['title'])
textbox_type(browser.find_element(:id, 'firstname'), user['first_name'])
textbox_type(browser.find_element(:id, 'surname'), user['last_name'])
textbox_type(browser.find_element(:id, 'label'), user['email'])
textbox_type(browser.find_element(:id, 'label2'), user['email'])
textbox_type(browser.find_element(:id, 'label3'), user['phone'])
textbox_type(browser.find_element(:id, 'address1'), "#{user['house_number']} #{user['road']}")
textbox_type(browser.find_element(:id, 'city'), user['town'])
textbox_type(browser.find_element(:id, 'county'), user['county'])
textbox_type(browser.find_element(:id, 'postcode'), user['postcode'])

# Do these two now, and then the user will be back where they need to fill in journey times
file_upload(browser.find_element(:id, 'uploadedfile_1'), File.absolute_path(ticket['path_to_ticket_image']))
browser.find_element(:name, 'confirmation').click

dropdown_select(browser.find_element(:id, 'ticket_type_1'), ticket['type'])
textbox_type(browser.find_element(:id, 'ticket_num_1'), ticket['light_blue_number'])
textbox_type(browser.find_element(:id, 'ticket_num2_1'), ticket['dark_blue_number'])
textbox_type(browser.find_element(:id, 'photocard_id_1'), user['photocard_id'])
textbox_type(browser.find_element(:id, 'cost_pounds_1'), ticket['pounds'])
textbox_type(browser.find_element(:id, 'cost_pence_1'), ticket['pence'].to_s[0, 2])

# Fill in today's date
today = Date.today
dropdown_select(browser.find_element(:id, 'journey_date_day_1'), today.day.to_s)
dropdown_select(browser.find_element(:id, 'journey_date_month_1'), Date::MONTHNAMES[today.month])
dropdown_select(browser.find_element(:id, 'journey_date_year_1'), today.year.to_s)

puts "Now fill in your journey details and the Captcha at the bottom of the page!"
