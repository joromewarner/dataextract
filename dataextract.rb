# Load Ruby Gems

require 'yaml'
require 'gmail'
require 'selenium-webdriver'

#Initialize

@url = "https://www.webpagetest.org"

@driver = Selenium::WebDriver.for :firefox

@wait = Selenium::WebDriver::Wait.new(:timeout => 300)


# Pass File Into Script

filename = "urls.txt"

list = File.new(filename, "r")

websites_from_file = list.readlines

list.close


#Looping The Website
#for urls in websites_from_file can also be used

emailbody = ""

websites_from_file.each do |urls|

@driver.navigate.to "#{@url}"


# Input to Test Website

websiteurl = @driver.find_element(:id, "url")

websiteurl.clear()

websiteurl.send_keys urls

# Click Button

submit_button = @driver.find_element(:class, "start_test")

submit_button.click

# Timeout/Idle code then check for elements

load_time = @wait.until {
  loading = @driver.find_element(:id, "LoadTime")
  loading if loading.displayed?
}

first_byte = @driver.find_element(:id, "TTFB")

puts "Test Passed" if load_time && first_byte
puts load_time.text, first_byte.text


emailbody = emailbody + "Values are #{load_time.text}(Load Time), #{first_byte.text}(First Byte), and is the website I used for #{urls}\n\n"

end


# Send Email

config = YAML.load_file("cred.yml")

gmail = Gmail.connect(config["config"]["email"], config["config"]["password"])

email = gmail.compose do
  to config["config"]["to"]
  subject "I did it!"
  body " #{emailbody} "
end

email.deliver!

gmail.logout

@driver.quit




