$res = $responses = $mongo.collection('responses')

RESPONSES_TABLE_FIELDS = ["_id", "user_id", "text", "request_id", "latitude", 
	"longitude", "photos_arr", "videos_arr", "created_at", "updated_at"]

MAX_RESPONSES_PER_REQUEST = 4

def map_responses(items)
	items.map! do |old|
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
	return items
end

get '/responses/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/response_page?response_id=', 
		ajax_link: '/responses/ajax', 
		keys: RESPONSES_TABLE_FIELDS,
		collection_name: "Responses"})
	else	
		{responses: $res.all}
	end
end

post '/responses/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue RESPONSES_TABLE_FIELDS.find_index('created_at')
	sort_field = RESPONSES_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $responses.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |req| 
		req['updated_at']     ||= nil
		req.values ||= nil 
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $responses.count,
  "recordsFiltered": $responses.count,
  "data": data
}
end


get '/response_page' do
	full_page_card(:"other/collection_page", locals: {
		data: $res.get({_id:params[:response_id]}),  
		keys: RESPONSES_TABLE_FIELDS,
		collection_name: "Responses"})
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
	{items:items}
end



post '/create_response' do 

	if !params[:request_id]
		return {err: "missing parameters"}
	end
	
	require_user
	request = $ir.find({_id:params[:request_id]}).to_a
	return {err:"no such request"} if !request

	# Max 4 responses per requests
	if $res.count({request_id:params[:request_id]}) > MAX_RESPONSES_PER_REQUEST-1
		halt_bad_input(msg:"you can't add more than" + MAX_RESPONSES_PER_REQUEST.to_s + " responses")
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

get '/edit_response' do
	response = $responses.update_id(params[:response_id], params) 
	{response: response}
end

get '/delete_response' do
	response = $responses.delete_one(_id: params[:response_id])
	{msg: "response removed"}
end


