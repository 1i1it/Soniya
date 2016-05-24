$conref = $confirm_refute =  $mongo.collection('confirm_refute')


def confirm_refute
		#receive token and response_id and action (confirm/refute/none)
	require_user
	response = $responses.get({_id:params[:response_id]})

	#if response has conref from this user
	conref = $conref.get({response_id:params[:response_id], user_id: cuid})
	if conref
		$conref.update_id(conref['_id'], {action: params[:action]}) 
		{msg: "refute/confirm changed"}
	else
		#if not
		$conref.add({user_id: cuid, response_id:response['_id'], action: params[:action]})
		{msg: "refute/confirm added"}
	end
end

post '/confirm_refute' do
	confirm_refute
end

get '/confirm_refute' do
	confirm_refute
end



get '/confirm_refute/all' do
	{confirm_refute: $confirm_refute.all}
end