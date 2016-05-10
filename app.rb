puts "starting app..."

require 'bundler'

require 'active_support'
require 'active_support/core_ext'

require 'sinatra/reloader' #dev-only
require 'sinatra/activerecord'

puts "requiring gems..."

Bundler.require

Dotenv.load

require './setup'
require './my_lib'

require_all './db'
require_all './mw'
require_all './comm'
require_all './bl'

include Helpers

def render_home_page
  erb :"wekudo/main_page", layout: :layout
end

get '/ping' do
  {msg: 'pong from pauzzitive', val: 123}
end

# fb app token: EAAOxuLF0mJkBAH8r1ykzjhq5xeZCQ6WEZAb7TtcWNQ2eZBW887Lf9AYW3a10WvIJLWsD3uiXT9TZBgZAPwi2adBxCBLr14hVHorjjedy3W6gEPM6Gg3ZCUBfcHLFo6tZCu4fflBYIHfofzqoQ67W2pZABd87GLUSJCeFIIkTgGLeOAZDZD


def print_msg
  puts Time.now.to_s
  puts "received params: ".blue
  puts JSON.pretty_generate(params).light_blue
  puts "---"  
end

def kinky_text
  "Something kinky."
end

def handle_msg 
  print_msg
  return params['hub.challenge'] if params['hub.challenge']
  data = fb_msg_data(params)
  user_id, text = data[:user_id], data[:text]

  response_msg = "I got: #{text}. In reverse it is: #{text.reverse}"
  response_msg = LiterateRandomizer.sentence if text == 'random' rescue 'oopsie'
  response_msg = kinky_text if text == 'test'
  send_fb_msg(user_id, response_msg)
rescue => e
  {msg: "some error occurred"}
end

get '/webhook' do
  handle_msg  
end

post '/webhook' do
  handle_msg
end



get '/' do
  #flash.message = "hello this is a flash"
  #render_home_page  
  #bp
  {msg: 'pauzzitive home'}
end

get '/ko' do
  erb :"ko_page", default_layout
end

# get '/:slug' do
#   slug = params[:slug]
#   if user = $users.get(username: slug)
#     render_user_page(user)
#   else
#     halt(404)
#   end
# end
