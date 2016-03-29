AIRTABLE_API_KEY=ENV['AIRTABLE_API_KEY']

def get_airtable_table(table_name)
  res = RestClient.get("https://api.airtable.com/v0/apph2lJagGf9lFU95/Venues?maxRecords=1000&view=Main%20View&api_key=#{AIRTABLE_API_KEY}")
  JSON.parse(res)['records']
end

def get_airtable_vendors
  vendors = get_airtable_table('vendors')
  vendors_with_name = vendors.map {|v| v['fields']}.select {|v| v['Name'].present? }
end