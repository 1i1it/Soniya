$site_log = $mongo.collection('site_log')

def log_event(data)
  data = {event: data} unless data.is_a? Hash
  data = data.just(:event, :subevent, :data)
  more_data = {username: cusername, email: cuemail, cuid: cuid, path: request_path, params: _params}.compact
  data = data.merge(more_data)
  $site_log.add(data)
rescue => e
  log_e(e)
  nil
end

get '/log_event' do
  log_event("hello")
end