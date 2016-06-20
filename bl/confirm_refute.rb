$conref = $confirm_refute =  $mongo.collection('confirm_refute')

CONREF_TABLE_FIELDS = ["_id", "user_id", "response_id", 
						"action", "created_at", "updated_at"]

get '/confirms_refutes/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/confirms_refutes_page?conref_id=', 
		ajax_link: '/confirms_refutes/ajax', 
		keys: CONREF_TABLE_FIELDS,
		collection_name: "Confirms and Refutes"})
	else	
		{confirm_refute: $conref.all}
	end
end

post '/confirms_refutes/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue CONREF_TABLE_FIELDS.find_index('created_at')
	sort_field = CONREF_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $conref.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |conref| 
		new_item = {}; CONREF_TABLE_FIELDS.map {|f| new_item[f] = conref[f] || '' }
			new_item.values
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $conref.count,
  "recordsFiltered": $conref.count,
  "data": data
}
end
	

def confirm_refute
	# can add confirm, refute to confirm/refute; or nil for removing confirm/refute
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
		$conref.add({user_id: cuid, response_id:response['_id'], 
			action: params[:action], request_id:params[:request_id]})
		{msg: "refute/confirm added"}
	end
	
end

post '/create_confirm_refute' do
	confirm_refute
end

get '/confirms_refutes_page' do
	full_page_card(:"other/collection_page", locals: {
		data: $conref.get({_id:params[:conref_id]}),  
		keys: CONREF_TABLE_FIELDS,
		collection_name: "Confirm/Refute"})
end


get '/confirms_refutes' do
	if params[:conref_id]
		items = $conref.get({_id:params[:conref_id]} ) 
	elsif params[:request_id]
		items = $conref.get_many({request_id:params[:request_id]}, sort: [{created_at: -1}] ) 

	elsif params[:user_id] 
		items = $conref.get_many({user_id: params[:user_id]}, sort: [{created_at: -1}] )
	else
		status 400
		return {error: "No such parameter. Choose from legal parameters conref_id, user_id, request_id"}
	end
	{items:items}
end