$users = $mongo.collection('users')

def create_user(data)
  $users.add(data)
end

def signin(email)
  user = email.present? && $users.get(email: email)
end


post '/users/signup' do
  user = signin(params[:email]) || create_user(email: params[:email])
  session[:user_id] = user[:_id]
  redirect '/'
end