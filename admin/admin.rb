MANAGEABLE_COLLECTIONS = [:users,:errors,:site_log,:requests, :info_requests, :responses, :contact_us, :confirm_refute].map {|n| $mongo.collection(n) }

get '/admin' do
  to_page(:"admin/dashboard")
end

get '/admin/api_spec' do
  erb :"admin/api_spec", default_layout
end

get "/admin/manage/:coll" do 
  erb :"admin/items", default_layout
end 

def is_admin(user = cu)
  return true 
  email = user['email'] 
  return true if email == 'sella.rafaeli@gmail.com' 
  return true if email == 'lily.matveyeva@gmail.com'
  return false
rescue 
  false
end

before '/admin*' do
  halt(404) unless is_admin
end

def verify_admin_val(collection, field, val)
  # if you want to verify admin value, you can do it by collection
  # and/or field 
  # mock-code
  # if collection == 'something'
  #   if field == 'something'
  #     halt_bad_input(msg: 'Bad input')

  if field == 'latitude' || field == 'longitude'
      val = val.to_f
  end
  val
end

post '/admin/create_item' do
  require_fields(['coll'])
  coll = $mongo.collection(params[:coll])
  fields = mongo_coll_keys(coll)
  data   = params.just(fields)
  coll.add(data)
  redirect back
end

post '/admin/update_item' do
  require_fields(['id','field','coll'])
  coll, field, val = params[:coll], params[:field], params[:val]
  verified_val = verify_admin_val(coll, field, val)
  res = $mongo.collection(params[:coll]).update_id(params[:id],{field => verified_val})
  {msg: "ok", new_item: res}
end

post '/admin/delete_item' do
  require_fields(['id','coll'])
  $mongo.collection(params[:coll]).delete_one({_id: params[:id]})
  {msg: "ok"}
end