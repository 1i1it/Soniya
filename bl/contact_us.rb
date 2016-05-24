$contact = $contact_us =  $mongo.collection('contact_us')

=begin
=end
get '/contact_form' do
  erb :"contact_us/contact_form", layout: :layout
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