Rails.application.routes.draw do
  post 'monzo_hook_receiver/transaction'
end
