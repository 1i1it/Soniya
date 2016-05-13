$kv = $mongo.collection('key_vals')

def kv_get(key)
  ($kv.get(key) || {})['val']
end

def kv_set(key,val)
  res = $kv.update_id(key, {val: val, updated_at: Time.now}, upsert: true)
  res['val']
end