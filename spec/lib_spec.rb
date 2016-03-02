#require './app'
Bundler.require
# comm
$http = HTTPClient.new
#$http = RestClient
$base_url = 'http://localhost:9393'
GET  = :GET
POST = :POST
PUT  = :PUT 

def bp
  binding.pry
end

def full_route(relative_route)
  "#{$base_url}#{relative_route}"
end

def parse_http_response(res)  
  JSON.parse res.body rescue res.body
end

def get_request(route, params = {}) 
  @last_res = parse_http_response (get_raw(route, params))
end

def get_raw(route, params = {})
  @last_res = $http.get full_route(route), params
end

def post_request(route, params = {})
  @last_res = parse_http_response (post_raw(route, params))
end

def post_raw(route, params = {})  
  @last_res = ($http.post full_route(route), params)
end

def put_request(route, params = {})
  @last_res = parse_http_response (put_raw(route, params))
end

def put_raw(route, params = {})
  @last_res = ($http.put full_route(route), params)
end

def last_res 
  @last_res
end

$assert_counter = 0
def assert(cond, msg = "<msg missing>") 
  $assert_counter += 1
  line = cond ? msg.green : "*** Failed *** on #{msg}".red
  line = "[#{$assert_counter}] #{line}"
  puts line[0..500]
  #puts ("---")
end

def test_response(tests, idx, success_test_method, opts = {})
  data      = tests[idx]
  method    = data[0]  
  
  route     = data[1]
  route     = opts[:route_prefix].to_s + route
  params    = data[2]
  params    = params.to_h.merge(opts[:extra_params] || {})
  
  if (method == PUT) 
    res = put_request(route, params) 
  elsif (method == GET) 
    res = get_request(route, params)
  elsif (method == POST) 
    res = post_request(route, params)
  end

  success = method(success_test_method).call(idx, res)
  
  msg = "#{idx}: #{method.upcase} #{route}"    
  msg += " with params #{params}, res was #{res}" if !success

  assert(success, msg)
end