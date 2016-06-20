use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

def request_expects_json?
  request.xhr? || !request.path_info.starts_with?("/admin") 
end

def request_is_public?
  request_path.to_s.starts_with?('/css/','/js/','/img/','/favicon/','/HTTP/') rescue false 
end

OPEN_ROUTES = ['/ping', '/fb_enter', '/login', '/about']

def is_open_route
  return true if request_is_public?
  return true if request_path.to_s.in?(OPEN_ROUTES)
  return false
end

before do
  require_user unless is_open_route     
  @time_started_request = Time.now    
end

def cu 
  # return current user
  if request.path_info.starts_with?("/admin")
    @cu ||= session && session[:user_id] && $users.get(session[:user_id]) rescue nil #for tux
  else
    @cu ||= params && params[:token] && $users.get(token: params[:token]) rescue nil #for tux
  end
end

def cu_token
   params && params[:token] && $users.get(token: params[:token]) rescue nil #for tux
  end

def cu_session
  session && session[:user_id] && $users.get(session[:user_id]) rescue nil #for tux
  end

def cu
   # return current user
   if request.path_info.starts_with?("/admin")
    @cu = cu_session
   else

    @cu = cu_token || cu_session || nil
    #bp
  end
end


def cuid 
  cu && cu['_id']
end

def cusername 
  cu && cu['username']
end

def cuemail
  cu && cu['email']
end

def request_path
  _req.path rescue nil #for tux
end

def request_fullpath
  _req.fullpath rescue nil #for tux 
end

def _req 
  request rescue OpenStruct.new #allows us to call 'request' safely, including within tux
end

def _params #allows us to call 'params' safely, including within tux
  params rescue {}
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

def params_val(key, opts = {})
  params[key].present? ? params[key] : ( (opts && opts[:default]) ? opts[:default] : nil )
end