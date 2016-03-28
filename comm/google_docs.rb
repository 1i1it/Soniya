#https://docs.google.com/spreadsheets/d/1a8LaRk7yX6COz455CexQjnM8lqkeCaFJEUIwyc8szug/pubhtml
#

WEKUDO_PAGES_JSON = "https://spreadsheets.google.com/feeds/list/1a8LaRk7yX6COz455CexQjnM8lqkeCaFJEUIwyc8szug/1/public/values?alt=json"

def spreadsheet_to_array(uri) #google_doc_to_array_of_rows
    JSON.parse(open(uri).read)['feed']['entry'].map { |row| kvs = row.select {|k,v| k.start_with?("gsx$") } }.map {|row| row = row.map {|k,v| [k.sub("gsx$",""),v["$t"] ]; }.to_h }
end



