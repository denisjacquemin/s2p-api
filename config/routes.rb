Rails.application.routes.draw do

  get 'messages', to: 'api#messages'
  get 'code_label/:code', to: 'api#code_label'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
