$ir = $info_requests = $mongo.collection('info_requests')
=begin
=end

PAGE_SIZE = 2
LOCATION_CHANGE = 0.01
QUERY_LIMIT = 100
REQUESTS_TABLE_FIELDS = ["_id", "user_id", "text", "location", "medium", "amount", "latitude", "longitude", "status", "is_private", "created_at", "paypal_pay_key", "updated_at", "paid"]


get '/pay' do #?receives id=123
	require_user
    info_request = $ir.get(params[:id])
    #info_request = {_id: $ir.get(params[:id])[_id], amount:456} 
    res = build_paypal_payment_page(info_request) #???? but it has to get amount as well?
    return res if res[:err]
    redirect res[:url]
end



get '/paypal_confirm' do #?receives request_id=123
	require_user
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


def map_requests(items)
  items.map! do |old|
    responses = $res.get_many_limited({request_id: old['_id']}, sort: [{created_at: -1}] ) #$res.find({request_id: old['_id']}).to_a
    responses = map_responses(responses)
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
  return items
end



get '/requests_page' do

	user = cu
	page_num = (params[:page_num] || 0).to_i
	data = $ir.get_many_limited({}, sort: [{created_at: -1}])	
	full_page_card(:"info_requests/requests_page", locals: {data: data, search: true})
	end

get "/request_page" do
	if params[:search_field] && params[:search_field] == "request_id"
		request = $ir.get({_id:params[:search_value]})
		responses = $res.get_many_limited({request_id:params[:search_value]}, sort: [{created_at: -1}] )
	else

		request = $ir.get({_id:params[:request_id]})
		responses = $res.get_many_limited({request_id:params[:request_id]}, sort: [{created_at: -1}] )
	end
	full_page_card(:"info_requests/request_page", locals: {request: request, responses: responses})
	end

get '/requests_list' do
	full_page_card(:"other/paginated_requests", locals: {search: true})
	end
	
post '/add_new_request' do 
	# # get user token from current user 
	# if !params[:token]
	# 	return {err:"missing parameter token"}
	# end
	user = cu
	#(return an error if no such user exists).
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
  					is_private:params[:is_private]})

  {request:request} 

end

get '/requests/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue REQUESTS_TABLE_FIELDS.find_index('created_at')
	sort_field = REQUESTS_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $ir.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |req| 
		req['paypal_pay_key'] ||= nil
		req['updated_at']     ||= nil
		req['paid']           ||= nil 
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
		return {error: "No such parameter. Please choose from legal parameters location, text, user_id, request_id"}
	end
	#data = map_requests(items)
	full_page_card(:"info_requests/requests_page", locals: {data: items})
	
end


get '/add_new_request_form' do
  erb :"info_requests/requests_index", layout: :layout
end

get '/search_form' do
  erb :"other/search_form", layout: :layout
end

get '/requests_by_text' do
	if !params[:text]
		return {err:"missing parameter text"}
	end
	items = $ir.find({text:params[:text]}).to_a
	{items:items}
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

get '/requests_around_me' do
	if !params[:latitude] || !params[:longitude]
		return {err:"missing parameters latitude and longitude"}
	end

	items = $ir.find({ 
		latitude: {
			"$gt": params[:latitude].to_f - LOCATION_CHANGE, 
			"$lt": params[:latitude].to_f + LOCATION_CHANGE},
		longitude: {
			"$gt": params[:longitude].to_f - LOCATION_CHANGE, 
			"$lt": params[:longitude].to_f + LOCATION_CHANGE}
			}).limit(QUERY_LIMIT).to_a
	full_page_card(:"info_requests/requests_page", locals: {data: items})
end

get '/requests/info' do
	{num: $ir.count}
end

get '/requests/all' do
	{requests: $ir.all}
end


