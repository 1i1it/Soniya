def default_layout
  {layout: :layout}
end

def escape_html(html, opts = {})
  Rack::Utils.escape_html(html.to_s)
end