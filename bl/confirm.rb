$confirm = $mongo.collection('confirm')

post '/confirm_response' do
	# receives response_id and token

	require_user
	user = cu
	# check if refute exists and delete it??, ook by response_id
	#if user same as added refute, and refute for response
	exists# call def unrefute_response

	refute = $refute.get({response_id:params[:response_id]}) 
	
	$refute.delete_one({_id:params[:refute_id]}) if refute && (cuid = refute["user_id"])
	

	response = $responses.get({_id:params[:response_id]})
	return {err:"no such response"} if !response

	refute = $confirm.add({user_id: user['_id'], response_id:response['_id']})

  {confirm:confirm} 
end

def unconfirm_response
	# receives response_id and token
	require_user
	refute = $confirm.get({_id:params[:confirm_id]}) || {}
	halt_bad_input(msg:"Can't, not yours") if (cuid != confirm["user_id"])
	
	$confirm.delete_one({_id:params[:confirm_id]})
	{msg: "confirm deleted"}
end

post '/unconfirm_response' do
	unrefute_response
end

get '/unconfirm_response' do
	unrefute_response
end

# if user refuted response, confirm unrefutes it


