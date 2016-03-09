after do 
  if @response.body.is_a? Hash #return hashes as json
    @response.body[:time] = Time.now - @time_started rescue nil
    content_type 'application/json'
    @response.body = @response.body.to_json   
  end 
end

