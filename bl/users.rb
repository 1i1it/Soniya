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
  # should show a table (HTML <table>) of all users, and for each user show 
  # their _id, email, name, created_at. Sort the list by created_at, 
  # showing newest users on top. 
  erb :"users/user_details", default_layout
end 

get "/user_page" do
  user_id = cuid || params[:user_id]
  #receives cuid 
  #Should show a table of their requests, and then a table of their responses 
  #(each will show the major fields - user_id, text, lat & long, etc). 
  erb :"users/user_page", default_layout
end 


get '/me' do
  #mock
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