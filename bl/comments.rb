$comments = $mongo.collection('comments')

COMMENTS_TABLE_FIELDS = ["_id", "user_id", "text", "response_id", "created_at", "updated_at"]

get '/comments/all' do
	if params[:browser]
		full_page_card(:"other/paginated_form", locals: {
		page_link: '/comments_page?comment_id=', 
		ajax_link: '/comments/ajax', 
		keys: COMMENTS_TABLE_FIELDS,
		collection_name: "Comments"})
	else	
		{comments: $comments.all}
	end
end

post '/comments/ajax' do
	limit = (params[:length] || 10).to_i
	skip  = (params[:start]  ||  0).to_i
	col_num = params[:order]["0"]["column"] rescue COMMENTS_TABLE_FIELDS.find_index('created_at')
	sort_field = COMMENTS_TABLE_FIELDS[col_num.to_i	]
	sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
	data = $comments.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |comm| 
		new_item = {}; COMMENTS_TABLE_FIELDS.map {|f| new_item[f] = comm[f] || '' }
			new_item.values
	}
	res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $comments.count,
  "recordsFiltered": $comments.count,
  "data": data
}
end

post '/create_comment' do
	user = cu
	flash.message = 'Please log in to post request' if !user 
	require_user
    comment = $comments.add({user_id: user['_id'], 
    			   	text:params[:text],
  					response_id:params[:response_id],	
  					request_id:params[:request_id]})
	{comment: comment}
end

get '/edit_comment' do
	comment = $comments.update_id(params[:comment_id], {text: params[:text]}) 
	{comment: comment}
end


get '/remove_comment' do
	comment = $comments.delete_one(_id: params[:comment_id])
	{msg: "comment removed"}
end

get '/comments_page' do
	full_page_card(:"other/collection_page", locals: {
		data: $comments.get({_id:params[:comment_id]}),  
		keys: COMMENTS_TABLE_FIELDS,
		collection_name: "Comment"})
end

get '/comments' do
	if params[:comment_id]
		items = $comments.get({_id:params[:comment_id]} ) 
	elsif params[:request_id]
		items = $comments.get_many({request_id:params[:request_id]}, sort: [{created_at: -1}] ) 
	elsif params[:user_id] 
		items = $comments.get_many({user_id: params[:user_id]}, sort: [{created_at: -1}] )
	else
		status 400
		return {error: "No such parameter. Choose from legal parameters comment_id, user_id, request_id"}
	end
	{items:items}
end



