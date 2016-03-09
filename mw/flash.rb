# thx to http://www.seanbehan.com/roll-your-own-session-based-flash-messaging-w-sinatra
# Simple flash messages
# flash = FlashMessage.new(session)
# flash.message = 'hello world'
# flash.message # => 'hello world'
# flash.message # => nil
class FlashMessage
  def initialize(session)
    @session ||= session
  end

  def message=(message)
    @session[:flash] = message
  end

  def message
    message = @session[:flash] #tmp get the value
    @session[:flash] = nil # unset the value
    message # display the value
  end
end

helpers do
  def flash
    @flash ||= FlashMessage.new(session)
  end
end