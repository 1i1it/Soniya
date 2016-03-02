puts "starting app..."

require 'bundler'
require 'active_support/core_ext'
require 'sinatra/reloader' #dev-only

puts "requiring gems..."
Bundler.require

require './setup'
require './users'
require './my_lib'

require_all './db'
require_all './mw'
require_all './bl'

get '/' do
  erb :index
end

get '/ping' do
  {msg: '123 pong from BEAPI', pong: true}
end