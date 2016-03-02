# usage: bundle exec ruby spec/spec.rb 
start = Time.now
puts "Running spec. Time is #{start}"
env   = ARGV[0] 
cur_dir = File.expand_path(File.dirname(__FILE__))

require 'pry-byebug'
require "#{cur_dir}/lib_spec.rb"
require 'faker'
require 'colorize'

puts "Loaded colorize. Hope for the best.".green
NEW_USERNAME_1   = Faker::Name.name
USER_ID = 'evq3bpg'
POST_ID = 'FxCMAf5NbA'
OTHER_USERNAME   = Faker::Name.name
tests = {
  :ping => [GET, '/ping', {}],
  :create_user => [PUT, '/api/users', {_method: 'put', name: Faker::Name.name, email: Faker::Internet.email, username: NEW_USERNAME_1}],
  :get_existing_user => [GET, "/api/users/#{USER_ID}", {}],
  :update_user => [POST, "/api/users/#{USER_ID}",{username: OTHER_USERNAME}],

  :create_post => [PUT, '/api/posts', {user_id: USER_ID, text: 'hello world'}],
  :get_post => [GET, "/api/posts/#{POST_ID}"],
  :get_posts_by_user_id => [GET, "/api/posts/#{POST_ID}",{user_id: USER_ID}],
  :get_posts_by_mongo_crit => [GET, '/api/posts', {mongo_crit_json: {"text": {"$regex": 'worl'}}.to_json}],
}

def expected_results(idx, res)
  success = case idx
  when :ping         
    res['pong'] == true
  when :create_user 
    res['item']['username'] == NEW_USERNAME_1 
  when :get_existing_user
    res['items'][0]['_id']  == USER_ID
  when :update_user
    res['item']['username'] == OTHER_USERNAME
  when :create_post
    res['item']['text']    == 'hello world'
  when :get_post 
    res['items'][0]['_id']  == POST_ID
  when :get_posts_by_user_id 
    res['items'][0]['user_id']  == USER_ID
  when :get_posts_by_mongo_crit
    res['items'][0]['text'].include?('world')
  else
    puts "No expectation function defined for idx #{idx}".yellow
    false
  end
rescue => e 
end

test_cases = Array(tests.keys)

test_cases.each do |idx| 
  test_response(tests, idx, :expected_results, {})
end
puts "took #{Time.now-start} seconds."