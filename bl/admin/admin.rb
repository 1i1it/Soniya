MANAGEABLE_COLLECTIONS = [:users,:posts,:errors,:site_log].map {|n| $mongo.collection(n) }

get '/admin' do
  erb :"admin/dashboard", default_layout
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

post '/admin/update_item' do
  halt_missing_fields(['id','field','coll']) unless params.just(:field,:id,:coll).size == 3
  coll, field, val = params[:coll], params[:field], params[:val]
  verified_val = verify_admin_val(coll, field, val)
  res = $mongo.collection(params[:coll]).update_id(params[:id],{field => verified_val})
  {msg: "ok", new_item: res}
end