get '/experiences' do
  full_page_card(:"wekudo/experiences")
end 

get "/c/:category" do
  full_page_card(:"wekudo/category")
end

get '/contact' do
  full_page_card(:"wekudo/contact")
end