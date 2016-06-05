$flags = $mongo.collection('flags')

=begin
* Payments ====missing====
- user_id (paying user)
- request_id
- amount 
- paid_user_id
- confirmed_paid_at
- transaction_id 

* Payments  ====missing====
- /prepare_payment_page
 - expects request_id 
 - returns URL of Paypal page ready for payment + pay-key (Paypal 
 identifier for payment)

- /confirm_payment 
 - expects payment identifier (string), returns hash indicating 
 confirmed payment status 
=end

get "confirm_payment" do
=begin
 - expects payment identifier (string), returns hash indicating 
 confirmed payment status 
=end

end 

get "prepare_payment_page" do
=begin
	 - expects request_id 
 - returns URL of Paypal page ready for payment + pay-key (Paypal 
 identifier for payment)
=end

end 

get "/payments" do
	user = cu
	erb :"payments/payments", layout: :layout
end 
