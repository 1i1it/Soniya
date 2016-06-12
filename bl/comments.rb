$comments = $mongo.collection('comments')

get '/comments' do

	{comments: $comments.all}
end

post '/add_comment' do
	user = cu
	flash.message = 'Please log in to post request' if !user 
	require_user

    	comment = $comments.add({user_id: user['_id'], 
    				text:params[:text],
  					response_id:params[:response_id]})
	{comment: comment}
end

get '/remove_comment' do
	comment = $comments.delete_one(_id: params[:comment_id])
	{msg: "comment removed"}
end


get '/edit_comment' do
	comment = $comments.update_id(params[:comment_id], {text: params[:text]}) 
	{comment: comment}
end

