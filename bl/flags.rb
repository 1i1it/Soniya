$flags = $mongo.collection('flags')

=begin
- flagging_user_id (cuid)
- flagged_user_id
- request_id/response_id 

-/flag_user (expects  cuid, flagged_user_id, request_id/response_id, returns new object flag added)
-/unflag_user (expects  cuid, flagged_user_id, request_id/response_id, returns - flag removed)
-/flags (expects one or more of the following: flagging_user_id, flagged_user_id, request_id/response_id, returns found objects)
=end

get '/flag_user' do
	 #(expects  cuid, flagged_user_id, request_id/response_id, returns new object flag added)
	if params[:response_id]
		response = $res.get(_id:params[:response_id])
		flag = $flags.add({flagging_user_id: cuid, flagged_user_id: response[:user_id], response_id: params[:response_id]})
	elsif params[:request_id]
		request = $ir.get(_id:params[:request_id])
		flag = $flags.add({flagging_user_id: cuid, flagged_user_id: request[:user_id], request_id: params[:request_id]})
	end
	{flag:flag}
	
end

get '/unflag_user' do
	if params[:response_id]
		response = $res.get(_id:params[:response_id])
		 $flags.delete_one({flagging_user_id: cuid, flagged_user_id: response[:user_id], response_id: params[:response_id]})

	elsif params[:request_id]
		request = $ir.get(_id:params[:request_id])
		$flags.delete_one({flagging_user_id: cuid, flagged_user_id: request[:user_id], request_id: params[:request_id]})

	end
	{msg:"flag deleted"}
end

get '/flags' do

	{flags:$flags.all}
end

get '/flags_page' do
	if params[:flagged_user_id]
		item = $flags.get_many_limited({flagged_user_id:params[:flagged_user_id]})
	elsif params[:flagging_user_id]
		item = $flags.get_many_limited({flagging_user_id:params[:flagging_user_id]})
	elsif params[:flag_id]
		item = $flags.get_many_limited({_id:params[:flag_id]})
	else		
		item = $flags.get_many_limited({}, sort: [{created_at: -1}] )
	
	end
	full_page_card(:"flags/flags", locals: {data: item})
end
