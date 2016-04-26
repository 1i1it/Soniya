$app_name   = 'homemade'
require './app'
run Sinatra::Application
puts "#{$app_name} is now running."