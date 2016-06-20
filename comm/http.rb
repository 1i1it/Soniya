def http_post(route, data = {}, headers = {})
  RestClient.post(route, data)
end

def http_get(route, data = {}, headers = {})
  RestClient.get(route, data)
end

def http_post_json(route, data = {}, headers = {})
  headers.merge!({content_type: :json, accept: :json})
  http_post(route, data, headers)
end