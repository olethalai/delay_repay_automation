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
    puts "Reading #{field}..."
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

# Open the delay repay form
browser = Selenium::WebDriver.for(:firefox)
browser.navigate.to('http://www.thameslinkrailway.com/contact-us/delay-repay/claim-form/')
sleep(1)

# User details
dropdown_select(browser.find_element(:id, 'title'), user['title'])
textbox_type(browser.find_element(:id, 'firstName'), user['first_name'])
textbox_type(browser.find_element(:id, 'surname'), user['last_name'])
textbox_type(browser.find_element(:id, 'email'), user['email'])
textbox_type(browser.find_element(:id, 'confirmEmail'), user['email'])
textbox_type(browser.find_element(:id, 'contactPhoneNumber'), user['phone'])
textbox_type(browser.find_element(:id, 'addressline1'), "#{user['house_number']} #{user['road']}")
textbox_type(browser.find_element(:id, 'towncity'), user['town'])
textbox_type(browser.find_element(:id, 'postcode'), user['postcode'])
# Wait for form validation to kick in
sleep(1)
browser.find_element(:css, 'button.pull-right.text-sm.btn.btn-primary').click
sleep(1)

# Claim details
textbox_type(browser.find_element(:xpath, "//select[@placeholder='Type of ticket']"), ticket['type'])
textbox_type(browser.find_element(:xpath, "//input[@placeholder='Cost of ticket']"), "#{'%.02f' % ticket['cost']}")
textbox_type(browser.find_element(:xpath, "//input[@placeholder='5-digit number']"), ticket['light_blue_number'])
textbox_type(browser.find_element(:xpath, "//input[@placeholder='Ticket number']"), ticket['dark_blue_number'])
textbox_type(browser.find_element(:xpath, "//input[@placeholder='Photocard number']"), user['photocard_id'])
browser.execute_script(%q(document.querySelector("div.col-sm-6 input[type=file]").style.display='block'))
file_upload(browser.find_element(:xpath, "//input[@type='file']"), File.absolute_path(ticket['path_to_ticket_image']))

puts "Now fill in your journey details and proceed to the next page to select your compensation method."
