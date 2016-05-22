$ir = $info_requests = $mongo.collection('info_requests')
=begin
=end

def map_requests(items)
  items.map! do |old|
    responses = $res.find({request_id: old['_id']}).to_a
    responses = map_responses(responses)
    new_request = {
      request_id:old['_id'],
      text: old[:text],
      request_location: old[:location],
      medium: old[:medium],
      amount: old[:amount],
      responses: responses,
      is_expensive: (old[:amount].to_i > 10)
    }
  end
  return items
end

get '/requests' do
	if params[:text]
		items = $ir.search_by("text", params[:text])
	elsif params[:location]
		items = $ir.search_by("location", params[:location])
	elsif params[:request_id]
		items = $ir.find({_id:params[:request_id]}).to_a
	elsif params[:user_id]
		items = $ir.find({user_id:params[:user_id]}).to_a
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters location, text, user_id, request_id"}
	end
	items = map_requests(items)
	{items:items}
end


get '/add_new_request_form' do
  erb :"info_requests/requests_index", layout: :layout
end

get '/requests_by_text' do
	if !params[:text]
		return {err:"missing parameter text"}
	end
	items = $ir.find({text:params[:text]}).to_a
	{items:items}
end

post '/add_new_request' do 
	# get user token from current user 
	if !params[:token]
		return {err:"missing parameter token"}
	end
	#(return an error if no such user exists).
	user = cu
	return {err:"no such user"} if !user 
    request = $ir.add({user_id: user['_id'], 
    				text:params[:text],
  					location:params[:location],
  					medium:params[:medium],
  					amount:params[:amount],
  					latitude:params[:latitude],
  					longitude:params[:longitude],
  					status:params[:status],
  					is_private:params[:is_private]})

  {request:request} 
end

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

get '/requests_by_location' do
	if !params[:location]
		return {err:"missing parameter location"}
	end
	items = $ir.find({location:params[:location]}).to_a
	{items:items}
end

get '/requests/info' do
	{num: $ir.count}
end

get '/requests/all' do
	{requests: $ir.all}
end

