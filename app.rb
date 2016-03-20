puts "starting app..."

require 'bundler'
require 'active_support/core_ext'
require 'sinatra/reloader' #dev-only

puts "requiring gems..."
Bundler.require

require './setup'
require './my_lib'

require_all './db'
require_all './mw'
require_all './bl'

include Helpers

get '/ping' do
  {msg: '123 pong from SNM', pong: true}
end

def render_home_page
  if !cu
    erb :index, layout: :layout
  else 
    full_page_card(:"my_er/user")
  end
end


get '/' do
  #flash.message = "hello this is a flash"
  render_home_page  
end

# get '/:slug' do
#   slug = params[:slug]
#   if user = $users.get(username: slug)
#     render_user_page(user)
#   else
#     halt(404)
#   end
# end
