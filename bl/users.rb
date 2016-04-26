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

post '/signin' do
  user = signin(params[:email]) || create_user(email: params[:email])
  session[:user_id] = user[:_id]
  redirect '/'
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

get '/signup' do
  erb :"users/signup", layout: :layout
end