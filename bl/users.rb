$users = $mongo.collection('users')

def create_user(data)
  #data[:username] = data[:email]
  $users.add(data)
end

def signin(email)
  user = email.present? && $users.get(email: email)
end

def user_permalink(user)
  $root_url + "/#{user['username']}"
end

def render_user_page(user)
  full_page_card(:"users/single_user", locals: {user: user})
end


get '/login' do
  erb :"users/login", layout: :layout
end

post '/login' do
  email, password = params[:email], params[:password]
  bp
  if $users.exists?(email: email)
    user = $users.get(email: email)
    if BCrypt::Password.new(user['hashed_pass']) == password
      session[:user_id] = user[:_id]     
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
    redirect '/' 
  end
end

get '/enterByCode' do
  user = $users.get(code: params[:code])
  if user 
    session[:user_id] = user[:_id]
  else 
    flash.message = 'No patient found with that code.'
  end
  
  redirect back
end

get '/logout' do
  session.clear
  redirect '/'
end