$users = $mongo.collection('users')

MANAGEABLE_COLLECTIONS = [:users,:errors,:site_log,:requests, :info_requests].map {|n| $mongo.collection(n) }

def create_user(data)
  data[:token] = SecureRandom.uuid
  $users.add(data)
end

=begin
get "/user_info/:coll/" do 
   #create a /user_info route that receives a user_id and displays an HTML 
  #page showing that user's requests and responses in separate lists.
  #requests
  #responses
  erb :"users/user_info", default_layout
end 
=end

get "/user_info/:token/:coll1/:coll2" do 
   #create a /user_info route that receives a user_id and displays an HTML 
  #page showing that user's requests and responses in separate lists.
  #requests
  #responses
  erb :"users/user_iterate", default_layout
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