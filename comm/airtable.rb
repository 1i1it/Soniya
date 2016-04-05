AIRTABLE_API_KEY=ENV['AIRTABLE_API_KEY']

def get_airtable_table(base_name, table_name)  
  res = RestClient.get("https://api.airtable.com/v0/#{base_name}/#{table_name}?maxRecords=1000&view=Main%20View&api_key=#{AIRTABLE_API_KEY}")
  records = JSON.parse(res)['records']
  fields  = records.map {|v| v['fields'] }.select{|v| v.any? }
end

# def get_airtable_vendors
#   vendors = get_airtable_table('apph2lJagGf9lFU95','Venues')
#   vendors_with_name = vendors.map {|v| v['fields']}.select {|v| v['Name'].present? }
# end

def update_deals_from_airtable
  update_coll_from_airtable('appJlAaCffqT76suq','Deals',$deals)
end

def update_coll_from_airtable(airtable_base, airtable_table, coll)
  puts "Updating #{coll.name} from Airtable."
  items = get_airtable_table(airtable_base, airtable_table) #get_airtable_table('apph2lJagGf9lFU95','Venues')
  if items.size > 1 
    coll.delete_many
    items.each {|item| coll.add(item) } 
    puts "Updated, we now have #{items.size} items."
  else 
    puts "Did not find records to add."
  end
end
