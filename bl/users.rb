$users = $mongo.collection('users')

MANAGEABLE_COLLECTIONS = [:users,:errors,:site_log,:requests, :info_requests].map {|n| $mongo.collection(n) }

def create_user(data)
  data[:token] = SecureRandom.uuid
  $users.add(data)
end

get "/user_info/:token/:coll1/:coll2" do 
   #create a /user_info route that receives a user_id and displays an HTML 
  erb :"users/user_iterate", default_layout
end 

get "/users" do 
  erb :"users/user_list", default_layout
end 

get "/admin/block_user" do
    halt(404) unless is_admin
    user = $users.find_one_and_update({_id: params[:user_id]}, {'$set' => {blocked: true}}) 
    flash.message = "user blocked"
    redirect back

end


get "/admin/unblock_user" do
    halt(404) unless is_admin
    user = $users.find_one_and_update({_id: params[:user_id]}, {'$set' => {blocked: false}}) 
    flash.message = "user unblocked"
    redirect back

end

get "/fb_enter" do

  user = http_get("https://graph.facebook.com/me?fields=name,email,picture&access_token="+params[:token])
  user_hash = JSON.parse(user)
  fb_id = user_hash["id"]
  existing_user = $users.get(fb_id: fb_id)
  if existing_user
     session[:user_id] = existing_user['_id']
     is_new = false
  else
    picture = user_hash["picture"]["data"]["url"]  rescue nil

    token = SecureRandom.uuid
    new_user = $users.add(email:user_hash["email"], pic_url:picture,  fb_id: fb_id, name:user_hash["name"], token: token)
    session[:user_id] = new_user['_id']
    is_new = true
  end
  new_user = $users.get(fb_id: fb_id)
  if params[:browser] 
    redirect "/" 
  else
    {user:new_user, is_new:is_new}
  end
end

get "/user_data" do 

  user = $users.get({_id: cuid })
  #(expects user_id, returns a hash with email, name, pic_url)
  user = {
      email:user[:email],
      name: user[:name],
      pic_url: user[:pic_url]
    }
  {user:user}
end 

def map_users(items)
  items.map! do |old|
    users = $users.get_many_limited({_id: old['_id']}, sort: [{created_at: -1}] )
    new_user = {
      email:old['email'],
      name: old[:name],
      picture_url: old[:picture_url]
    }
  end
  return items
end

get "/update_me" do
  $users.find_one_and_update({_id: cuid}, {'$set' => params}) 
  #(expects one of the following and sets it: [paypal, email, pic_url, name.] 
  {user:cu}
end 

get "/activity_data" do
  activity_data = {
  user_id:cuid,
  num_requests_made:$ir.count({user_id:cuid}),
  num_responses:$res.count({user_id:cuid}),
  num_requests_marked_as_fulfilled:0,
  num_paid_requests_marked_as_fulfilled:0,
  num_actual_paid:0,
  }
  {activity_data:activity_data}
  # returns of activity_data:
  # - num_requests_made
  # - num_responses
  # - num_requests_marked_as_fulfilled
  # - num_paid_requests_marked_as_fulfilled
  # - num_actual_paid

end 


get "/user_page" do
  user_id = params[:user_id] || cuid
  user =  $users.get(_id: user_id) 
  #receives cuid 
  #Should show a table of their requests, and then a table of their responses 
  #(each will show the major fields - user_id, text, lat & long, etc). 
  full_page_card(:"users/user_page", locals: {data: user})
end 



get '/me' do
  {user:cu}
end
get '/login' do
  erb :"users/login", layout: :layout 
end

post '/login' do
  email, password = params[:email], params[:password]
  if $users.exists?(email: email)
    user = $users.get(email: email)
    if BCrypt::Password.new(user['hashed_pass']) == password      
      session[:user_id] = user[:_id]     
      log_event('logged in') 
      redirect '/' 
    else
      flash.message = 'Wrong password.'

      # ADD warning message
      redirect back
    end
  else
     flash.message = 'No such email.' 
     redirect back
  end  
end

get '/register' do
  erb :"users/register", layout: :layout
end

post '/register' do
  email, password = params[:email], params[:password]
  if $users.exists?(email: email)
    flash.message = 'Email already taken.'
    redirect back
  else 
    user = create_user(email: email, hashed_pass: BCrypt::Password.create(password))
    session[:user_id] = user[:_id]     
    log_event('registered')
    redirect '/' 
  end
end

get '/enterByCode' do #??
  user = $users.get(code: params[:code])
  if user 
    session[:user_id] = user[:_id]
  else 
    flash.message = 'No patient found with that code.'
  end
  
  redirect back
end

get '/logout' do
  log_event('logged out')
  session.clear
  redirect '/'
end