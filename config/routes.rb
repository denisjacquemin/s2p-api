Rails.application.routes.draw do

  get 'messages', to: 'api#messages'
  get 'getfullnamebycode/:code', to: 'api#get_fullname_by_code'
  get 'linkcodetodevice', to: 'api#link_code_to_device'
  get 'unlinkcodetodevice', to: 'api#unlink_code_to_device'
  get 'disabledevicenotifictation', to: 'api#disabledevicenotifictation'
  get 'enabledevicenotifictation', to: 'api#enabledevicenotifictation'
  get 'saveregistrationid', to: 'api#saveregistrationid'
  get 'resetcodeonserver', to: 'api#resetcodeonserver'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
