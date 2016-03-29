MANAGEABLE_COLLECTIONS = [:pages,:vendors,:users,:errors,:site_log,:requests].map {|n| $mongo.collection(n) }

get '/admin' do
  to_page(:"admin/dashboard")
end

post '/admin/create_user' do
  require_fields([:phone,:case_id])

  data = params.just(:phone,:case_id)
  data[:code] = nice_id
  user = create_user(data)
  flash.message = "Patient's code is #{user[:code]}. We will also send him an SMS to #{user[:phone]} (not yet implemented.)"
  redirect back
end

get "/admin/manage/:coll" do 
  erb :"admin/items", default_layout
end 

def is_admin(user = cu)
  true
end

before '/admin*' do
  halt(404) unless is_admin
end

def verify_admin_val(coll, field, val)
  if coll == 'posts'
    if field == 'photos'
      halt_bad_input(msg: 'Bad photos')
    end
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