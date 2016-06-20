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
require_all './admin'
require_all './bl'
require_all './comm'
require_all './logging'
require_all './mw'

include Helpers

$app_name   = 'Soniya/Raven'

get '/ping' do
  {msg: "pong from #{$app_name}", val: 123}
end

# fb app token: EAAOxuLF0mJkBAH8r1ykzjhq5xeZCQ6WEZAb7TtcWNQ2eZBW887Lf9AYW3a10WvIJLWsD3uiXT9TZBgZAPwi2adBxCBLr14hVHorjjedy3W6gEPM6Gg3ZCUBfcHLFo6tZCu4fflBYIHfofzqoQ67W2pZABd87GLUSJCeFIIkTgGLeOAZDZD

get '/' do
  redirect '/about'
end
