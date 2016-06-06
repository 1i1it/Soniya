$prod       = settings.production? #RACK_ENV==production?
$prod_url   = 'http://my-er.herokuapp.com/'
$root_url   = $prod ? $prod_url : 'http://localhost:9292'

enable :sessions
set :session_secret, '&a*n31994@'
set :raise_errors,          false
set :show_exceptions,       false
set :erb, :layout =>    false

def bp
  binding.pry
end

def get_fullpath
  $root_url + request.fullpath
end

configure :development, :production do
 db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///testdb')

 ActiveRecord::Base.establish_connection(
   :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
   :host     => db.host,
   :username => db.user,
   :password => db.password,
   :database => db.path[1..-1],
   :encoding => 'utf8'
 )
end

class Post < ActiveRecord::Base
end

class Author < ActiveRecord::Base
end