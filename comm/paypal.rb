PAYPAL_USERNAME=ENV['PAYPAL_USERNAME']
PAYPAL_PASSWORD=ENV['PAYPAL_PASSWORD']
PAYPAL_SIGNATURE=ENV['PAYPAL_SIGNATURE']

PayPal::SDK.configure(
    :mode      => "sandbox",  # Set "live" for production
    :app_id    => "APP-80W284485P519543T",
    :username  => PAYPAL_USERNAME,
    :password  => PAYPAL_PASSWORD,
    :signature => PAYPAL_SIGNATURE)



def build_paypal_payment_page(info_request)
  paypal_api = PayPal::SDK::AdaptivePayments.new
  return_url = $root_url+'/paypal_confirm?request_id='+info_request['_id'] 
  cancel_url = $root_url+'/paypal_cancel?request_id='+info_request['_id'] 
  amount     = info_request['amount'].to_f

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


# The info_request should have saved in it the 'paypal_pay_key'.
#  So what we can do now is confirm whether this payment indeed has been paid. 
#  	We will first define a method for it:

def get_paypal_payment_details(pay_key)  
  paypal_api = PayPal::SDK::AdaptivePayments.new
  #call paypal to confirm payment
  details = paypal_api.payment_details({payKey: pay_key}).to_hash.hwia  #??hwia

  details[:confirmed_paid] = details['status'].to_s.in?(['COMPLETED', 'PROCESSED'])
  details
end

=begin
At this point, the paypal_data should hold the information about whether 
the payment has indeed been completed. Since we are getting this information directly 
from paypal we can trust it of course. So now we know whether the request has been paid for, 
and we can mark it accordingly and so on.

6. Practice and build a complete flow:
What I suggest is:
a. Go other the above once or twice to hopefully understand how it all works.
b. copy the methods into paypal.rb and execute them a few times manually (via tux) 
to see the results; complete the flow of paying for items a few times. 
c. build the appropriate routes. On a 'request page' (Not sure if we have one yet,
 if not then after we have one) put an indication if the request has been paid already 
	('paid: true/false'). And show 'pay now' button for the request if the viewing user is
	 the owner (and the request has not been paid yet). Clicking on 'pay now' should create 
	 a payment page and redirect the user to it. 
d. After the user pays he should return to the /paypal_confirm route, which will verify 
the request has been paid (and if so mark it accordingly with a 'paid: true' flag). 

For reference, you can see my implementation of this on my 'barry2' project (the marketplace).
 Its a bit difference (since I want to allow every item to be purchased multiple times,
  not just once) - but the Paypal-interaction is very similar: 
 https://github.com/SellaRafaeli/barry2/blob/master/comm/paypal.rb


##############
Go over the lines and try to understand what each line does. The 'return_url' means to which 
URL Paypal will send the user after the user paid; cancel_url is the same. Prefacing a
 variable like "@pay" with a '@' does not mean much - it will just make the variable 
 available in other methods as well (I don't use that, it's just because I copied this 
 	code off some examples I found offline and didn't bother to change it. Also it makes 
 	the variable seem 'important' which I kind of like.).

So after configuring the parameters, we invoke the .build_pay method. You should be able to
 follow the parameters passed more or less; then we pass the object to .pay. This is just 
 "the way the gem is used"; it doesn't matter to me. The point is the result of this action 
 should generally be an object with a pay_key (an identifier of the payment) and a url.
  It is important to note that no payment has been performed yet; we're just preparing 
  the page for the user. 

If everything has been set up correctly, you should now be able to invoke this method 
from tux, i.e. something like:

>> build_paypal_payment_page({"_id" => '123', "amount" => 456})
{:success=>true, :url=>"https://www.sandbox.paypal.com/webscr?cmd=_ap-payment&paykey=AP-7M976138CY240725P", :payKey=>"AP-7M976138CY240725P"}

Now what we would do is take the URL and redirect the user to the URL.
 We can test this by opening the URL ourselves in the browser and seeing that is indeed a
  payment for that info request. (We should also send stuff like the description of what 
  the user is paying for etc; I still haven't found how to do that with this gem.)

So we haven't yet connected it to the appropriate routes, but we can see the
 direction: when a user wants to pay for a info_request, 
 we'll activate this method on that info_request and get an appropriate URL to 
  redirect him to for payment. Something like:
=end

 