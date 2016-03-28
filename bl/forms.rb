$forms_posted = $mongo.collection('forms_posted')

POST_FORM_WHITE_FIELDS = [:which_form,:name,:email,:text]

post '/post_form' do
  data  = params
  #data = params.just(POST_FORM_WHITE_FIELDS)
  $forms_posted.add(data)
  redirect '/refer'
end

get '/admin/forms_posted' do
  full_page_card(:"admin/forms_posted")
end