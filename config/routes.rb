Rails::Application.routes.draw do 
  resources :comments,:only=>:none do
    resource :comments, :only=>[:edit,:update,:create,:new,:index,:destroy] do
      get :reply, :on=>:member
    end
  end
end