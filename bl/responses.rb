$res = $responses = $mongo.collection('responses')
=begin
=end

def map_responses(items)
	items.map! do |old|
	#user = $users.get({_id:old[:user_id]}),

	  new_request = {
	  	description: old[:text],
	  	user_name:$users.get({_id:old[:user_id]})[:name], 
	  	response_id: old[:_id],
	  	request_id: old[:request_id],
	  	latitude: old[:latitude],
	  	longitude: old[:longitude],
	  	photos_arr: old[:photos_arr],
	  	videos_arr: old[:videos_arr]
	  }
	end
	#bp
	return items
end

get '/response_page' do
	user = cu
	item = $res.get({_id:params[:response_id]})
	erb :"responses/response_page", layout: :layout
	end

get '/responses' do
	if params[:text]
		items = $res.search_by("text", params[:text])
	elsif params[:response_id]
		items = $res.get_many_limited({_id:params[:response_id]}, sort: [{created_at: -1}] ) 
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

	if !params[:request_id]
		return {err: "missing parameters"}
	end
	
	require_user
	request = $ir.find({_id:params[:request_id]}).to_a
	return {err:"no such request"} if !request

	# Max 4 responses per requests
	if $res.count({request_id:params[:request_id]}) > 14
		halt_bad_input(msg:"Sorry, you can't add more than 4 responses")
	end
    response = $res.add({user_id: cuid, 
    				text: params['text'],
    				request_id:params[:request_id],
  					latitude:params[:latitude],
  					longitude:params[:longitude],
  					photos_arr:params[:photos_arr],
  					videos_arr:params[:videos_arr]})

  {response:response} 

end
