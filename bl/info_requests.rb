$ir = $info_requests = $mongo.collection('info_requests')
$users = $mongo.collection('users')

 get '/requests_by_user_id' do
	if !params[:user_id]
		return {err:"missing parameter user_id"}
	end
	items = $ir.find({user_id:params[:user_id]}).to_a

	items.map! do |item|
	  name = item[:name]
	  location = item[:location]
	  new_hash = {request_name: name, place: location}
	end
	{requests:items}

end

 get '/requests' do
  $ir.add({user_id:params[:user_id], text:params[:text]})
end

get '/foo' do
	{requests: [ 
			{name: 'Jerusalem', question: 'How many people?'}
	]}
end

get '/requests/info' do
	{num: $ir.count}
end

get '/requests/add' do
		$ir.add({a:1})
end

get '/requests/all' do
	{requests: $ir.all}
end

get '/requests/truth' do
	{android: 'Is clearly the best phone ever', }
end

 #add a route that gets a request by location (where the location of the request
 # matches the request location).


post '/requests' do
  $ir.add({name:params[:name], location:params[:location]})
end

get '/create_request' do # ??should be get or post?
	if !params[:token]
		return {err:"missing parameter token"}
	end
	#(return an error if no such user exists).
	user = $users.get(token: params[:token])
	return {err:"no such user"} if !user
  user = $users.get(token: params[:token]) #??diff between find and get
  request = $ir.add({user_id: user['_id'], name:params[:name], location:params[:location]})
  {request:request} 
end

get '/requests_by_location' do
	if !params[:location]
		return {err:"missing parameter location"}
	end
	items = $ir.find({location:params[:location]}).to_a
	{items:items}
end