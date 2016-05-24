=begin
or have 1 collection confirm_refute
receive token and response_id and action (confirm/refute/none)
each item will have: user_id, response_id , status (con/ref)
if we do smth, we update status
=end

	
	#halt_bad_input(msg:"Can't, not yours") if (cuid != refute["user_id"])
	
	#$refute.delete_one({_id:params[:refute_id]})
	#{msg: "refute deleted"}

$refute = $mongo.collection('refute')
	


post '/refute_response' do
	# receives response_id and token

	# delete confirm if there's one

	require_user
	user = cu

	response = $responses.get({_id:params[:response_id]})
	return {err:"no such response"} if !response

	refute = $refute.add({user_id: user['_id'], response_id:response['_id']})

  {refute:refute} 
end

get '/refutes/all' do
	{refutes: $refute.all}
end

get '/refutes' do
	if params[:user_id]
		items = $refute.find({user_id:params[:user_id]}).to_a
	end
	{refutes: items}
end

def unrefute_response
	# receives response_id and token
	require_user
	refute = $refute.get({_id:params[:refute_id]}) || {}
	halt_bad_input(msg:"Can't, not yours") if (cuid != refute["user_id"])
	
	$refute.delete_one({_id:params[:refute_id]})
	{msg: "refute deleted"}
end

post '/unrefute_response' do
	unrefute_response
end

get '/unrefute_response' do
	unrefute_response
end
