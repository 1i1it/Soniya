def get_proposal_text(vendors_arr)
  vendors = vendors_arr.select {|x| x.present? }.map {|v| $vendors.get(ID: v)}

  if (vendors.size == 1)
    name1 = vendors[0]['Name'].to_s rescue "ERROR"
    str = erb :"wekudo/generated_proposal", locals: {vendors: vendors}
  else
    str = "Found no vendors."  
  end

  str
end


get '/admin/proposals' do
  if params[:vendors].present?
    params[:proposal_text] = get_proposal_text(params[:vendors])
  end
  to_page(:"wekudo/proposals")
end