$app_name = 'snm'

$root_url   = $prod ? $prod_url : 'http://localhost:9393'

enable :sessions
set :raise_errors,          false
set :show_exceptions,       false

def bp
  binding.pry
end

def get_fullpath
  $root_url + request.fullpath
end