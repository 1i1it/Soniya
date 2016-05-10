# pauzzitive - 

FB app: https://developers.facebook.com/apps/1039831739439257/
FB page: https://www.facebook.com/pauzzitive/?
Chatbot docs: https://developers.facebook.com/docs/messenger-platform/implementation#setup

Example payload:

{
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

Example sending message:

curl -X POST -H "Content-Type: application/json" -d '{
    "recipient":{
        "id": 997788726969575
    }, 
    "message":{
        "text":"hello, world!"
    }
}' "https://graph.facebook.com/v2.6/me/messages?access_token=EAAOxuLF0mJkBAKkUXvepZAPZBKAZBjnKUEjZAYuhbo8YjptoazvES9pVbZCBVzyCkogbMZCbmphZCz5KUtTKyxe6DFY93ZBCLlbJ4d4ftG3SZA2ywICo5ha7nrKg803ZC7THBfomwiRK62WeN6Yql990hZC3hsNBdeVt7OQkOutSMQGZBgZDZD"

#Sublime Keyboard shortcuts
http://docs.sublimetext.info/en/latest/file_management/file_management.html

# CSS Filewatcher:
$ filewatcher '**/*.scss' 'scss $FILENAME > $FILENAME.css; echo "created"-$FILENAME; date'

# Exclude searches:
-public/css/font*, -public/css/bootstrap_3.3.4.min.css, -public/css/lib*, -public/js/lib*, -*/node_modules/*, -*/js_dist/*, -*/.sass-cache*
