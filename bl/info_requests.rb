$ir = $info_requests = $mongo.collection('info_requests')

PAGE_SIZE 					= 2
LOCATION_CHANGE_LEVEL_ONE   = 0.01
LOCATION_CHANGE_LEVEL_TWO   = 0.1
LOCATION_CHANGE_LEVEL_THREE = 1
QUERY_LIMIT                 = 100
REQUESTS_TABLE_FIELDS       = ["_id", "user_id", "text", "location", "medium", 
						 "amount", "latitude", "longitude", "status", 
						 "is_private", "created_at", "paypal_pay_key",
						 "updated_at", "paid"]
REQUEST_STATUS_FULFILLED    = 'fulfilled'
REQUEST_STATUS_CLOSED       = 'closed'

post '/fulfill_request' do
	request = $ir.update_id(params[:request_id], status: REQUEST_STATUS_FULFILLED)
	{request: request}
end

post '/close_request' do
	request = $ir.update_id(params[:request_id], status: REQUEST_STATUS_CLOSED)
	{request: request}
end

get '/pay' do
    info_request = $ir.get(params[:id])  
    if !info_request
    	halt_bad_input(msg: 'Request id is wrong')
    end
    if info_request[:paid]
    	halt_bad_input(msg: 'Request has already been paid for')
    end


    fulfilling_response = $res.get(request_id: params[:id], is_fulfilling: RESPONSE_STATUS_FULFILLING)
 	responder_paypal_email = $users.get(_id: fulfilling_response["user_id"])["paypal_email"]
 	responder_paypal_email = 'sella.rafaeli@gmail.com' #for testing TODO
    res = build_paypal_payment_page(info_request, responder_paypal_email) 
    return res if res[:err]
    redirect res[:url]
end

get '/paypal_confirm' do 
     ir = $ir.get(params[:request_id])
     pay_key = ir['paypal_pay_key']
     paypal_data = get_paypal_payment_details(pay_key)
     if paypal_data[:confirmed_paid]
     	$ir.update_id(params[:request_id], paid:true) 
     	{request_id: params[:request_id], paid: true, msg: "ok, you paid"}
     else
     	{msg: "payment didn't go through"}
     end
end

get '/paypal_cancel' do
	redirect "/request_page?request_id="+params[:request_id] 
end

get '/requests/all' do
	if params[:browser] 
		full_page_card(:"other/paginated_requests", locals: {search: true})
	else
		{requests: $ir.all}
	end
end

get "/request_page" do
	request_id= params[:search_value] || params[:request_id]	
	request = $ir.get({_id:params[:request_id]})
	responses = $res.get_many_limited({request_id:params[:request_id]}, sort: [{created_at: -1}] )
	full_page_card(:"info_requests/request_page", locals: {request: request, responses: responses})
end

post '/add_new_request' do 
	user = cu
	#(return an error if no user
	flash.message = 'Please log in to post request' if !user 
	require_user	
	request = $ir.add({user_id: user['_id'], 
					text:params[:text],
					location:params[:location],
					medium:params[:medium],
					amount:params[:amount],
					latitude:params[:latitude],
					longitude:params[:longitude],
					status:params[:status],
					is_private:params[:is_private]
					})
  {request:request} 
end

post '/requests/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue REQUESTS_TABLE_FIELDS.find_index('created_at')
	sort_field = REQUESTS_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1	
	# jquery table expects an array of arrays of values: [['val1','val2','val3'], ['val1','val2','val3']]
	data = $ir.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |req| 
		pay_button_html = '<td> <a href="/pay?id=' +  req["_id"] + '"> <button type="button" class="btn btn-primary btn-sm">Pay now</button></a> </td>'
		req['paypal_pay_key'] ||= nil
		req['updated_at']     ||= nil
		req['paid']           ||= pay_button_html
		req.values 
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $ir.count,
  "recordsFiltered": $ir.count,
  "data": data
}
end

get '/requests' do
	params[params[:search_field]] = params[:search_value]
	if params[:text]
		items = $ir.search_by("text", params[:text])
	elsif params[:location]
		items = $ir.search_by("location", params[:location])
	elsif params[:request_id]
		items = $ir.get_many_limited({_id:params[:request_id]}, sort: [{created_at: -1}] ) 
	elsif params[:user_id]
		items = $ir.get_many_limited({user_id:params[:user_id]}, sort: [{created_at: -1}] )
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters 
						location, text, user_id, request_id"}
	end
	if params[:browser] 
		full_page_card(:"info_requests/requests_page", locals: {data: items})

	else
		{items:items}
	end
end

get '/add_new_request_form' do
  erb :"info_requests/request_form", layout: :layout
end

get '/search_form' do
  erb :"other/search_form", layout: :layout
end

get '/requests_by_text' do
	return {err:"missing parameter text"} if !params[:text]		
	items = $ir.find({text:params[:text]}).to_a
	{items:items}
end

get '/requests_by_user_id' do
	return {err:"missing parameter user_id"} if !params[:user_id]		
	items = $ir.find({user_id:params[:user_id]}).to_a
	items.map! do |item|
	  name = item[:name]
	  location = item[:location]
	  new_hash = {request_name: name, place: location}
	end
	{requests:items}
end

get '/requests_by_location' do
	return {err:"missing parameter location"} if !params[:location]		
	items = $ir.find({location:params[:location]}).to_a
	{items:items}
end

def get_items_around_coordinates(lat, lng, offset)
	 $ir.find({ latitude: {
			"$gte": params[:latitude].to_f - offset, 
			"$lte": params[:latitude].to_f + offset},
				longitude: {
			"$gte": params[:longitude].to_f - offset, 
			"$lte": params[:longitude].to_f + offset}}).to_a
end

get '/requests_around_me' do
	return {err:"missing parameters latitude and longitude"} if !params[:latitude] || !params[:longitude]		
	lat, lng = params[:latitude], params[:longitude]
	items_level1, items_level2, items_level3 = [], [], []

	items_level1 = get_items_around_coordinates(lat, lng, LOCATION_CHANGE_LEVEL_ONE)

	if items_level1.size < 10
		items_level2 = get_items_around_coordinates(lat, lng, LOCATION_CHANGE_LEVEL_TWO)
	end

	if items_level2.size < 10
		items_level3 = get_items_around_coordinates(lat, lng, LOCATION_CHANGE_LEVEL_THREE)
	end

	items = (items_level1 + items_level2 + items_level3).uniq
	if params["browser"]
		full_page_card(:"info_requests/requests_page", locals: {data: items})
	else
		{items:items}
	end
end

#INACTIVE FUNCTIONS
def map_requests(items)
	return 'disabled'
	items.map! do |old|
    responses = $res.get_many_limited({request_id: old['_id']}, sort: [{created_at: -1}] ) #$res.find({request_id: old['_id']}).to_a
    #responses = map_responses(responses)
    new_request = {
    	_id:old['_id'],
    	text: old[:text],
    	request_location: old[:location],
    	medium: old[:medium],
    	latitude: old[:latitude],
    	longitude: old[:longitude],
    	amount: old[:amount],
    	responses: responses,
    	is_expensive: (old[:amount].to_i > 10)
    }
	end
	items
end