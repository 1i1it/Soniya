$flags = $mongo.collection('flags')

FLAGS_TABLE_FIELDS = ["_id", "flagging_user_id", "flagged_user_id", "response_id", "created_at"]

get '/flags/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/flags_page?flag_id=', 
		ajax_link: '/flags/ajax', 
		keys: FLAGS_TABLE_FIELDS,
		collection_name: "flags"})
	else	
		{flags: $flags.all}
	end
end

post '/flags/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue FLAGS_TABLE_FIELDS.find_index('created_at')
	sort_field = FLAGS_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $flags.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |req| 
		req['updated_at']     ||= nil
		req.values ||= nil 
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $flags.count,
  "recordsFiltered": $flags.count,
  "data": data
}
end
get '/flag_user' do
	require_user
	 #(expects  cuid, flagged_user_id, request_id/response_id, returns new object flag added)
	if params[:response_id]
		response = $res.get(_id:params[:response_id])
		existing_flag = $flags.get({flagging_user_id: cuid, flagged_user_id: response[:user_id], response_id: params[:response_id]}) 
		if !existing_flag
			flag = $flags.add({flagging_user_id: cuid, flagged_user_id: response[:user_id], response_id: params[:response_id]}) 
		else
			return {msg: "flag exists"}
		end	
	elsif params[:request_id]
		request = $ir.get(_id:params[:request_id])
		existing_flag = $flags.get({flagging_user_id: cuid, flagged_user_id: request[:user_id], request_id: params[:request_id]}) 
		if !existing_flag
			flag = $flags.add({flagging_user_id: cuid, flagged_user_id: request[:user_id], request_id: params[:request_id]})
		else
			return {msg: "flag exists"}
		end	
	end
	{flag:flag}
	
end

get '/unflag_user' do
	require_user
	if params[:response_id]
		response = $res.get(_id:params[:response_id])
		 $flags.delete_one({flagging_user_id: cuid, flagged_user_id: response[:user_id], response_id: params[:response_id]})

	elsif params[:request_id]
		request = $ir.get(_id:params[:request_id])
		$flags.delete_one({flagging_user_id: cuid, flagged_user_id: request[:user_id], request_id: params[:request_id]})

	end
	{msg:"flag deleted"}
end


get '/flags_page' do
	if params[:flagged_user_id]
		item = $flags.get_many_limited({flagged_user_id:params[:flagged_user_id]})
	elsif params[:flagging_user_id]
		item = $flags.get_many_limited({flagging_user_id:params[:flagging_user_id]})
	elsif params[:flag_id]
		item = $flags.get_many_limited({_id:params[:flag_id]})
	else		
		{msg: "params missing"} 
	
	end
	full_page_card(:"flags/flags", locals: {data: item})
end
