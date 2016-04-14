Rails.application.routes.draw do

  get 'messages', to: 'api#messages'
  get 'getfullnamebycode/:code', to: 'api#get_fullname_by_code'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
