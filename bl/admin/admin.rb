get '/admin/items' do 
  erb :"admin/items", layout: :layout
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
  val = verify_admin_val(coll, field, val)
  res = $mongo.collection(params[:coll]).update_id(params[:id],{field => verified_val})
  {msg: "ok", new_item: res}
end