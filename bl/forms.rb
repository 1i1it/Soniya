$forms_posted = $mongo.collection('forms_posted')

POST_FORM_WHITE_FIELDS = [:which_form,:name,:email,:msg]

post '/post_form' do
  data = params.just(POST_FORM_WHITE_FIELDS)
  $forms_posted.add(data)
  redirect '/referral'
end