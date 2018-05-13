Rails.application.routes.draw do
  root 'sources#index'

  get ':name', to: 'sources#edit'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
