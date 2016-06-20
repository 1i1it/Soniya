$ratings = $mongo.collection('ratings')

RATINGS_TABLE_FIELDS = ["_id", "user_id", "rating", "response_id", "rated_user_id", "created_at", "updated_at"]

get '/ratings' do
	if params[:rating_id]
		items = $ratings.get({_id:params[:rating_id]} ) 
	elsif params[:request_id]
		items = $ratings.get_many({request_id:params[:request_id]}, sort: [{created_at: -1}] ) 
	elsif params[:user_id] 
		items = $ratings.get_many({user_id: params[:user_id]}, sort: [{created_at: -1}] )
	elsif params[:rated_user_id]
		items = $ratings.get_many({rated_user_id:params[:rated_user_id]}, sort: [{created_at: -1}] )
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters user_id, rated_user_id"}
	end
	{items:items}
end
	
get '/ratings/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/ratings_page?rating_id=', 
		ajax_link: '/ratings/ajax', 
		keys: RATINGS_TABLE_FIELDS,
		collection_name: "Ratings"})
	else	
		{ratings: $ratings.all}
	end
end

post '/ratings/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue RATINGS_TABLE_FIELDS.find_index('created_at')
	sort_field = RATINGS_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $ratings.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |rtng| 
		new_item = {}; RATINGS_TABLE_FIELDS.map {|f| new_item[f] = rtng[f] || '' }
		new_item.values
	}

	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $ratings.count,
  "recordsFiltered": $ratings.count,
  "data": data
}
end

post '/create_rating' do 
	require_user
	require_fields(params[:rating])
	if  !params[:response_id] && !params[:request_id]
		{err: "missing response id or request id"}
	end
	
	requesting_user = $ir.get(_id:params[:request_id])["user_id"]
	if requesting_user != cuid
		halt_bad_input(msg: "can't rate response, request is not yours")
	end

	response = $res.get({_id:params[:response_id]})
	return {err:"no such request"} if !request

	if response["user_id"] == cuid
		return {err: "can't rate yourself"}
	end

	existing_rating = $ratings.get({user_id:cuid, response_id:params[:response_id], rated_user_id:response["user_id"]})
	if existing_rating
		rating = $ratings.update_id(existing_rating['_id'], {rating: params[:rating]}) 
	else
    	rating = $ratings.add({user_id: cuid, 
    				rating:params[:rating],
    				response_id:params[:response_id],
  					rated_user_id:response["user_id"]},
  					request_id:params[:request_id])
    end

  {rating:rating} 
end

post '/update_rating' do
	$ratings.update_id(params[:id], {rating: params[:rating]}) 
 	{rating:rating} 
end 

get '/ratings_page' do
	full_page_card(:"other/collection_page", locals: {
		data: $ratings.get({_id:params[:rating_id]}),  
		keys: RATINGS_TABLE_FIELDS,
		collection_name: "Rating"})
end

