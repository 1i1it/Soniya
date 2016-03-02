error do 
  e = env['sinatra.error']  
  {msg: "an error occurred", e: e.backtrace.to_a.slice(0,4).to_s}
end
