$vendors = $mongo.collection('vendors')

def update_vendors_from_airtable

  vendors = get_airtable_vendors
  if vendors.size > 1 
    $vendors.delete_many 
    vendors.each {|vendor| $vendors.add(vendor) } 
  end
  redirect '/admin/manage/vendors'
end

get '/admin/update_vendors' do
  update_vendors_from_airtable
end