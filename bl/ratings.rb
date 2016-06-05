$ratings = $mongo.collection('ratings')
=begin
=end

get '/ratings' do
	if params[:user_id]
		items = $ratings.find({user_id:params[:user_id]}).to_a
	elsif params[:rated_user_id]
		items = $ratings.find({rated_user_id:params[:rated_user_id]}).to_a
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters user_id, rated_user_id"}
	end
	{items:items}
end

get '/ratings/all' do
	{ratings: $ratings.all}
end


post '/add_new_rating' do 
	#DO REQUIRE FIELDS
	if  !params[:response_id] && !params[:rating]
		return {err: "missing parameters"}
	end
	
	require_user

	response = $res.get({_id:params[:response_id]})
	return {err:"no such request"} if !request

	if response["user_id"] == cuid
		return {err: "can't rate yourself"}
	end

	#USE UPSERT
	#if this user already rated this response, change it
	existing_rating = $ratings.get({user_id:cuid, response_id:params[:response_id], rated_user_id:response["user_id"]})
	if existing_rating
		$ratings.update_id(existing_rating['_id'], {rating: params[:rating]}) 
	else
    rating = $ratings.add({user_id: cuid, 
    				rating:params[:rating],
    				response_id:params[:response_id],
  					rated_user_id:response["user_id"]})
    end

  {rating:rating} 

end
