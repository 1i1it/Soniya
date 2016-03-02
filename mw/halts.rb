def halt_missing_fields(fields)
  halt(403, {msg: "Missing fields: #{fields.join(",")}"}) 
end

def halt_item_exists(field, val = nil)
  halt(403, {msg: "Item exists with field: #{field} and val: #{val}"}) 
end

def halt_error(msg)
  halt(500, {msg: msg})
end

get '/halts' do
  {msg: 'halt!'}
end