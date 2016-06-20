PAYPAL_USERNAME =ENV['PAYPAL_USERNAME']
PAYPAL_PASSWORD =ENV['PAYPAL_PASSWORD']
PAYPAL_SIGNATURE=ENV['PAYPAL_SIGNATURE']
PAYPAL_APP_ID   =ENV['PAYPAL_APP_ID'] || 'APP-80W284485P519543T' #sandbox
PAYPAL_MODE     = 'sandbox' #$prod ? "live" : "sandbox"  # Set "live" for production
PayPal::SDK.configure(
    :mode      => PAYPAL_MODE,
    :app_id    => PAYPAL_APP_ID,
    :username  => PAYPAL_USERNAME,
    :password  => PAYPAL_PASSWORD,
    :signature => PAYPAL_SIGNATURE)

def build_paypal_payment_page(info_request, responder_email)
  paypal_api = PayPal::SDK::AdaptivePayments.new
  return_url = $root_url+'/paypal_confirm?request_id='+info_request['_id'] + "&token=" + $users.get("_id":info_request['user_id'])["token"]
  cancel_url = $root_url+'/paypal_cancel?request_id='+info_request['_id']  + "&token=" + $users.get("_id":info_request['user_id'])["token"]
  amount     = info_request['amount'].to_f
  responder_email = 'sella.rafaeli@gmail.com' #until we work in production
  @pay = paypal_api.build_pay({ # Build request object 
  	#receives array with user_id and amount e.g({"_id" => '123', "amount" => 456})
  	# returns array with status, return_url, payKey:
  	#{:success=>true, :url=>"https://www.sandbox.paypal.com/webscr?cmd=_ap-payment&paykey=AP-0CR14704K25991146", 
  	#  :payKey=>"AP-0CR14704K25991146"}

    :actionType => "PAY", 
    :currencyCode => "USD",
    :feesPayer => "EACHRECEIVER",
    :receiverList => { :receiver => [
      {:amount => amount, :email => "sella-admin2@gmail.com",}, 
    ]},
    # :receiverList => { :receiver => [
    #     {:amount => amount, :email => "sella.rafaeli@gmail.com", primary: true }, #'primary' when chaining
    #    {:amount => (0.8 * amount), :email => 'agam.rafaeli@gmail.com'}
    # ]},
    :returnUrl => return_url, 
    :cancelUrl => cancel_url})
  
  @pp_response = paypal_api.pay(@pay) # Make API call & response
  
  # Access response
  if @pp_response.success? && @pp_response.payment_exec_status != "ERROR"
    puts ("paykey: "+@pp_response.payKey.to_s).red
    paypal_pay_key = @pp_response.payKey
    $ir.update_id(info_request['_id'], {paypal_pay_key: paypal_pay_key}) #this line will be explained later
    {success: true, url: paypal_api.payment_url(@pp_response), payKey: paypal_pay_key} 
  else
    {err: @pp_response.error[0].message}
  end
end

def get_paypal_payment_details(pay_key)  
  paypal_api = PayPal::SDK::AdaptivePayments.new
  #call paypal to confirm payment
  details = paypal_api.payment_details({payKey: pay_key}).to_hash.hwia  #??hwia
  details[:confirmed_paid] = details['status'].to_s.in?(['COMPLETED', 'PROCESSED'])
  details
end

get '/paypal/refresh' do
  true
end