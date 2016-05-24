$contact = $contact_us =  $mongo.collection('contact_us')

=begin
Modify the form by adding inline CSS (that is, CSS defined on the 
'style' attribute of the form). Then move it from inline to just an internal
 <style> tag in the document.

=end
get '/contact_us' do
  full_page_card(:"contact_us/contact_form")
end

post '/contact_us' do
	if cu
		contact = $contact.add({user_id: cuid, 
    							text: params['text'],
    							email: params[:email]})

	else
		contact = $contact.add({text: params['text'],
    							email:params[:email]})
	end
	{contact: contact}
end

get '/contact/all' do
	{contact: $contact.all}
end