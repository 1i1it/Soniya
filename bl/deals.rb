$deals = $mongo.collection('deals')

def get_deals_by_name
end

get '/admin/update_deals_from_airtable' do
  update_deals_from_airtable
  redirect '/admin/manage/deals'
end