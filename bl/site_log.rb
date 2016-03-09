$site_log = $mongo.collection('site_log')

def log_event(data)
  data = data.just(:event, :subevent, :target, :time_took)
  data = data.merge({username: cusername, cuid: cuid, path: request_path, params: _params})
  $site_log.add(data)
end