$confirm = $mongo.collection('confirm')

post '/confirm_response' do
	# receives response_id and token

	require_user
	user = cu

	response = $responses.get({_id:params[:response_id]})
	return {err:"no such response"} if !response

	refute = $confirm.add({user_id: user['_id'], response_id:response['_id']})

  {confirm:confirm} 
end
