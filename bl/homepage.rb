def render_home_page
  if !cu
    erb :index, layout: :layout
  else 
    erb :index, layout: :layout
  end
end