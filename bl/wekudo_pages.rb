$pages = $wekudo_site_pages = $mongo.collection('pages')

WEKUDO_PAGES_SPREADSHEET_JSON = "https://spreadsheets.google.com/feeds/list/1a8LaRk7yX6COz455CexQjnM8lqkeCaFJEUIwyc8szug/1/public/values?alt=json"

def spreadsheet_to_array(uri) #google_doc_to_array_of_rows
    JSON.parse(open(uri).read)['feed']['entry'].map { |row| kvs = row.select {|k,v| k.start_with?("gsx$") } }.map {|row| row = row.map {|k,v| [k.sub("gsx$",""),v["$t"] ]; }.to_h }
end

def update_wekudo_pages
  pages = spreadsheet_to_array(WEKUDO_PAGES_SPREADSHEET_JSON).reverse
  if pages.size > 10 
    $pages.delete_many 
    pages.each {|page| $pages.add(page) } 
  end
  redirect '/admin/manage/pages'
end



get '/admin/update_pages' do
  update_wekudo_pages
end

get '/experiences' do
  #full_page_card(:"wekudo/experiences")
  to_page(:"wekudo/experiences")
end 

get "/nyc/:category" do
  to_page(:"wekudo/category")
end

get '/contact' do
  to_page(:"wekudo/contact")
end

get '/new-york/:type' do
  to_page(:"wekudo/contact")
end

get '/why_wekudo' do
  to_page(:"wekudo/why_wekudo")
end

get '/:page' do
  {page: params[:page]}
end