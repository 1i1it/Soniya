def request_expects_json
  request.path_info.starts_with? ("/api") || 
  request.xhr? || 
  false
end

before do     
  @time_started = Time.now    
end

def cu 
  @cu = session && session[:user_id] && $users.get(session[:user_id])
end

#get val from params
def params_num(key, opts = {})
  val = params[key]  
  
  return opts[:default] if !val.present? && opts[:default]  

  val = to_numeric(val)
  val = opts[:max] if opts[:max] && val > opts[:max].to_f
  val = opts[:min] if opts[:min] && val < opts[:min].to_f
  return val 
end
