$users = $mongo.collection('users')

def create_user(data)
  data[:username] = data[:email]
  $users.add(data)
end

def signin(email)
  user = email.present? && $users.get(email: email)
end

def user_permalink(user)
  $root_url + "/#{user['username']}"
end

def render_user_page(user)
  erb :"users/single_user", locals: {user: user}, layout: :layout
end

post '/signin' do
  user = signin(params[:email]) || create_user(email: params[:email])
  session[:user_id] = user[:_id]
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/signup' do
  erb :"users/signup", layout: :layout
end