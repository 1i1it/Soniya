after do 
  request_time = Time.now - @time_started_request rescue nil
  log_request({time_took: request_time}) unless request_is_public?
    
  if @response.body.is_a? Hash #return hashes as json
    @response.body[:time] = request_time
    content_type 'application/json'
    @response.body = @response.body.to_json   
  end 
end