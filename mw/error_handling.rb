$errors = $mongo.collection('errors')

module Helpers
  def log_e(err, data = {})  
    err = {msg: err.to_s, backtrace: err.backtrace.to_a.slice(0,4)} if err.is_a? Exception
    err = {} unless err.is_a? Hash
    err[:user_id]  = cuid
    err[:username] = cusername
    err[:path]     = request_path
    err[:params]   = get_params
    $errors.add(err)
  rescue => e
    nil
  end
end

error do 
  e = env['sinatra.error']    
  log_e(e)
  {msg: "an error occurred", e: e.to_s, backtrace: e.backtrace.to_a.slice(0,4).to_s}
end

not_found do
  if request_expects_json
    content_type 'application/json'
    status 404
    return {msg: 'Whoops, no such route.'}
  else 
    full_page_card(:"other/404")     
  end
end

get '/error' do
  a = b 
end


