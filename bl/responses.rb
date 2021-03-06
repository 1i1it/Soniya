$res = $responses = $mongo.collection('responses')

RESPONSES_TABLE_FIELDS = ["_id", "user_id", "text", "request_id", "latitude", 
	"longitude", "photos_arr", "videos_arr",  "is_fulfilling", "created_at", "updated_at"]

MAX_RESPONSES_PER_REQUEST = 4
RESPONSE_STATUS_FULFILLING = "fulfilling"
RESPONSE_STATUS_NOT_FULFILLING = "not_fulfilling"
RESPONSE_STATUS_UNMARKED = "unmarked"

def map_responses(items)
	items.map! do |old|
	  new_request = {
	  	response_id: old[:_id],
	  	description: old[:text],
	  	user_name:$users.get({_id:old[:user_id]})[:name], 
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
	data = $responses.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |rsp| 
		new_item = {}; RESPONSES_TABLE_FIELDS.map {|f| new_item[f] = rsp[f] || '' }
		new_item.values
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
		collection_name: "Response"})
end

get '/responses' do
	if params[:text]
		items = $res.search_by("text", params[:text])
	elsif params[:response_id]
		items = $res.get({_id:params[:response_id]}) 
	elsif params[:request_id]
		items = $res.get_many({request_id:params[:request_id]}, sort: [{created_at: -1}] )
	elsif params[:user_id]
		items = $res.get_many({user_id:params[:user_id]}, sort: [{created_at: -1}] )
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

	request = $ir.get({_id:params[:request_id]})
	halt_bad_input(msg:"no such request") if !request

	#can't add more responses if request is fulfilled or closed
	if (request["status"] == REQUEST_STATUS_FULFILLED) || (request["status"] == REQUEST_STATUS_CLOSED)
		halt_bad_input(msg:"this request is #{request["status"]}, can't post resposes")
	end

	# Max 4 responses per requests with fulfilled:UNMARKED
	if $res.count({request_id:params[:request_id], fulfilling:RESPONSE_STATUS_UNMARKED}) > MAX_RESPONSES_PER_REQUEST-1
		halt_bad_input(msg:"you can't add more than " + MAX_RESPONSES_PER_REQUEST.to_s + " responses")
	end
    
    response = $res.add({user_id: cuid, 
    				text: params['text'],
    				request_id:params[:request_id],
  					latitude:params[:latitude],
  					longitude:params[:longitude],
  					photos_arr:params[:photos_arr],
  					videos_arr:params[:videos_arr],
  					is_fulfilling:RESPONSE_STATUS_UNMARKED})

  {response:response} 
end

post '/edit_response' do
	response = $responses.update_id(params[:response_id], params.except("response_id")) 
	{response: response}
end

post '/delete_response' do
	response = $responses.delete_one(_id: params[:response_id])
	{msg: "response removed"}
end

post '/response_fulfilling' do	
	request_id = $responses.get(_id: params[:response_id])["request_id"]
	requesting_user_id =  $ir.get(_id: request_id)["user_id"]
	if cuid != requesting_user_id
		halt_bad_input(msg:"can't mark as fulfilled, not your request")
	end 
	
	response = $responses.update_id(params[:response_id], is_fulfilling:RESPONSE_STATUS_FULFILLING) 
	request  = $ir.update_id(request_id, status: REQUEST_STATUS_FULFILLED)
	{response: response}
end

post '/response_not_fulfilling' do
	response = $responses.update_id(params[:response_id], is_fulfilling:RESPONSE_STATUS_NOT_FULFILLING) 
	{response: response}
end


