$kv = $mongo.collection('key_vals')

def get_keyval(key)
  ($kv.get(key) || {})['val']
end

def set_keyval(key,val)
  res = $kv.update_id(key, {val: val, updated_at: Time.now}, upsert: true)
  res['val']
end

get '/apis' do
  
end