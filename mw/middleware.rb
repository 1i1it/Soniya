def is_api_request
  request.path_info.starts_with? ("/api")
end

before do     
  @time_started = Time.now    
end

def cu 
  @cu = session && session[:user_id] && $users.get(session[:user_id])
end

after do 
  if @response.body.is_a? Hash #return hashes as json
    @response.body[:time] = Time.now - @time_started rescue nil
    content_type 'application/json'
    @response.body = @response.body.to_json   
  end 
end

