$res = $responses = $mongo.collection('responses')
=begin
=end

def map_responses(items)
	items.map! do |old|
	  new_request = {
	  	description: old[:text],
	  	request_id: old[:request_id],
	  	latitude: old[:latitude],
	  	longitude: old[:longitude],
	  	photos_arr: old[:photos_arr],
	  	videos_arr: old[:videos_arr]
	  }
	end
	return items
end


get '/responses' do
	if params[:text]
		items = $res.search_by("text", params[:text])
	elsif params[:request_id]
		items = $res.find({request_id:params[:request_id]}).to_a
	elsif params[:user_id]
		items = $res.find({user_id:params[:user_id]}).to_a
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters location, text, user_id, request_id"}
		
	end
	items = map_responses(items)
	{items:items}
end

get '/responses/all' do
	{responses: $res.all}
end

post '/add_new_response' do 
	# receive request_id and user token

	if !params[:token] && !params[:request_id]
		return {err: "missing parameters"}
	end
	user = cu
	return {err:"no such user"} if !user 

	request = $ir.find({_id:params[:request_id]}).to_a
	return {err:"no such request"} if !request

	# Max 4 responses per requests
	if $res.count({request_id:params[:request_id]}) > 4
		halt_bad_input(msg:"Sorry, you can't add more than 4 responses")
	end
    response = $res.add({user_id: user['_id'], 
    				text: params['text'],
    				request_id:params[:request_id],
  					latitude:params[:latitude],
  					longitude:params[:longitude],
  					photos_arr:params[:photos_arr],
  					videos_arr:params[:videos_arr]})

  {response:response} 

end
