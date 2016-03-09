error do 
  e = env['sinatra.error']    
  {msg: "an error occurred", e: e.to_s, backtrace: e.backtrace.to_a.slice(0,4).to_s}
end

not_found do
  if request_expects_json
    content_type 'application/json'
    status 404
    return {msg: 'Whoops, no such route.'}
  else 
    erb :"other/404", layout: :layout
  end
end