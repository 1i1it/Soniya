FB_PAGE_TOKEN = ENV['FB_PAGE_TOKEN']
FB_ROUTE      = 'https://graph.facebook.com/v2.6/me/messages'

def send_fb_msg(user_id, text)
  data  = {recipient: {id: user_id}, message: {text: text}}
  route = FB_ROUTE+"?access_token=#{FB_PAGE_TOKEN}"
  http_post_json(route, data)  
end

def fb_msg_data(data)
  user_id = data[:entry][0][:messaging][0][:sender][:id]
  text    = data[:entry][0][:messaging][0][:message][:text]
  {user_id: user_id, text: text}
end

EXAMPLE_FB_PAYLOAD = {
  "object": "page",
  "entry": [
    {
      "id": 492664237595026,
      "time": 1462900319057,
      "messaging": [
        {
          "sender": {
            "id": 997788726969575
          },
          "recipient": {
            "id": 492664237595026
          },
          "timestamp": 1462900318917,
          "message": {
            "mid": "mid.1462900318906:acfb67c815f7160722",
            "seq": 15,
            "text": "hello14"
          }
        }
      ]
    }
  ]
}

def test_fb_msg
  send_fb_msg(997788726969575, 'hello world 3')
end
