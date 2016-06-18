$messages = $submitted_messages = $contact = $contact_us =  $mongo.collection('contact_us')

MESSAGES_TABLE_FIELDS = ["_id", "user_id", "name","text", "email", "created_at"]


get '/contact_us' do
 full_page_card(:"contact_us/contact_form")
end

post '/contact_us' do
	if cu
		contact = $contact.add({user_id: cuid, 
    							text: params['text'],
    							email: params[:email]})

	else
		contact = $contact.add({name: params['name'],
								text: params['text'],
    							email:params[:email]})
	end
	{contact: contact}
end

get '/submitted_messages/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/messages_page?message_id=', 
		ajax_link: '/messages/ajax', 
		keys: MESSAGES_TABLE_FIELDS,
		collection_name: "Submitted Messages"})
	else	
		{messages: $messages.all}
	end
end

post '/messages/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue MESSAGES_TABLE_FIELDS.find_index('created_at')
	sort_field = MESSAGES_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $messages.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |msg| 
			new_item = {}; MESSAGES_TABLE_FIELDS.map {|f| new_item[f] = msg[f] || '' }
			new_item.values 
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $messages.count,
  "recordsFiltered": $messages.count,
  "data": data
}
end

get '/messages_page?' do
	full_page_card(:"other/collection_page", locals: {
		data: $messages.get({_id:params[:message_id]}),  
		keys: MESSAGES_TABLE_FIELDS,
		collection_name: "Message"})
end


get '/messages' do
	if params[:user_id]
		items = $messages.find({user_id:params[:user_id]}).to_a
	elsif params[:email]
		items = $messages.find({email:params[:email]}).to_a
	elsif params[:message_id]
		items = $messages.find({_id:params[:message_id]}).to_a
	else
		status 400
		return {error: "No such parameter. Please choose from legal parameters user_id, email"}
	end
	{items:items}
end