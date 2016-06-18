$users = $mongo.collection('users')

MANAGEABLE_COLLECTIONS = [:users,:errors,:site_log,:requests, :info_requests].map {|n| $mongo.collection(n) }
USERS_TABLE_FIELDS = ["_id", "email", "pic_url", "fb_id", "name", "token", "created_at", "updated_at", "paypal_email"]


get '/user_history' do
  # requries token, returns requests user asked, requests user answered and responses user gave
  requests_asked = $ir.get_many_limited({user_id:cuid}, sort: [{created_at: -1}] )
  my_responses = $res.get_many_limited({user_id:cuid}, sort: [{created_at: -1}] ) rescue {}
  requests_responded =  my_responses.map {|response| $ir.get({_id:response[:request_id]}) } rescue {}
  {
  requests_i_asked: requests_asked,
  requests_i_answered: requests_responded,
  responses_given: my_responses
  }
  
end

get '/users/all' do
  if params[:browser]
    full_page_card(:"other/paginated_form", locals: {
    page_link: '/user_page?user_id=', 
    ajax_link: '/users/ajax', 
    keys: USERS_TABLE_FIELDS,
    collection_name: "Users"})
  else  
    {users: $users.all}
  end
end

post '/users/ajax' do
  limit = (params[:length] || 10).to_i
  skip  = (params[:start]  ||  0).to_i
  col_num = params[:order]["0"]["column"] rescue USERS_TABLE_FIELDS.find_index('created_at')
  sort_field = USERS_TABLE_FIELDS[col_num.to_i ]
  sort_dir   = (params[:order]["0"]["dir"] == 'asc' ? 1 : -1) rescue 1
  data = $users.find({}, sort: [{sort_field => sort_dir}]).skip(skip).limit(limit).to_a.map { |user| 
    new_item = {}; USERS_TABLE_FIELDS.map {|f| new_item[f] = user[f] || '' }
    new_item.values
  }
  res = {
  "draw": params[:draw].to_i,
  "recordsTotal": $users.count,
  "recordsFiltered": $users.count,
  "data": data
}
end

def create_user(data)
  data[:token] = SecureRandom.uuid
  $users.add(data)
end

get "/users" do 
  erb :"users/user_list", default_layout
end 

get "/admin/block_user" do
    halt(404) unless is_admin
    user = $users.find_one_and_update({_id: params[:user_id]}, {'$set' => {blocked: true}}) 
    flash.message = "user blocked"
    redirect back

end


get "/admin/unblock_user" do
    halt(404) unless is_admin
    user = $users.find_one_and_update({_id: params[:user_id]}, {'$set' => {blocked: false}}) 
    flash.message = "user unblocked"
    redirect back

end

get "/fb_enter" do
  user = http_get("https://graph.facebook.com/me?fields=name,email,picture&access_token="+params[:token])
  user_hash = JSON.parse(user)
  fb_id = user_hash["id"]
  existing_user = $users.get(fb_id: fb_id)
  if existing_user
     session[:user_id] = existing_user['_id']
     is_new = false
  else
    picture = user_hash["picture"]["data"]["url"]  rescue nil

    token = SecureRandom.uuid
    new_user = $users.add(email:user_hash["email"], pic_url:picture,  fb_id: fb_id, name:user_hash["name"], token: token)
    session[:user_id] = new_user['_id']
    is_new = true
  end
  new_user = $users.get(fb_id: fb_id)
  if params[:browser] 
    redirect "/" 
  else
    {user:new_user, is_new:is_new}
  end
end

get "/user_data" do 

  user = $users.get({_id: cuid })
  #(expects user_id, returns a hash with email, name, pic_url)
  user = {
      email:user[:email],
      name: user[:name],
      pic_url: user[:pic_url]
    }
  {user:user}
end 

get "/user_statistics" do 
# show statiscis_route for user: 
#   a. num of requests
# b, offered for payment
# c. fulfilled offered for payment
# d. .paid_requests.
  requests_number = $ir.get_many({user_id: cuid }).count
  offered_for_payment = $ir.get_many({user_id: cuid, amount: {'$exists': true} }).count
  fulfilled_offered_for_payment = $ir.get_many({user_id: cuid, amount: {'$exists': true}, status: REQUEST_STATUS_FULFILLED }).count
  paid_requests = $ir.get_many({user_id: cuid, paid: true }).count
  user = $users.get({_id: cuid })
  #(expects user_id, returns a hash with email, name, pic_url)
  {user_statistics: {
    user_id: cuid,
    requests_number: requests_number,
     offered_for_payment: offered_for_payment,
     fulfilled_offered_for_payment: fulfilled_offered_for_payment, 
     paid_requests: paid_requests
    }
  }
end 

def map_users(items)
  items.map! do |old|
    users = $users.get_many_limited({_id: old['_id']}, sort: [{created_at: -1}] )
    new_user = {
      email:old['email'],
      name: old[:name],
      picture_url: old[:picture_url]
    }
  end
  return items
end

get "/edit_user" do
  $users.find_one_and_update({_id: cuid}, {'$set' => params.except(:id)}) 
  #(expects one or mmore of the following and sets it: [paypal_email, email, pic_url, name.] 
  {user:cu}
end 

get "/activity_data" do
  activity_data = {
  user_id:cuid,
  num_requests_made:$ir.count({user_id:cuid}),
  num_responses:$res.count({user_id:cuid}),
  num_requests_marked_as_fulfilled:0,
  num_paid_requests_marked_as_fulfilled:0,
  num_actual_paid:0,
  }
  {activity_data:activity_data}

end 


get "/user_page" do
  user_id = params[:user_id] || cuid
  user =  $users.get(_id: user_id) 
  #receives cuid 
  #Should show a table of their requests, and then a table of their responses 
  #(each will show the major fields - user_id, text, lat & long, etc). 
  full_page_card(:"users/user_page", locals: {data: user})
end 



get '/profile' do
  {user:cu}
end


get '/login' do
  erb :"users/login", layout: :layout 
end


get '/logout' do
  log_event('logged out')
  session.clear
  redirect '/login'
end