def render_home_page
  erb :index, layout: :layout
end

get '/' do
  render_home_page  
end
