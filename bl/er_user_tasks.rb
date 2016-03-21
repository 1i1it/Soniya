get '/user_tasks' do
  {html: (erb :"my_er/user_tasks_content")}
end