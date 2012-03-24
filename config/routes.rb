Meishi::Application.routes.draw do
  devise_for :users, :path => :user

  # Yeah, map this under the devise controller. Shouldn't conflict since
  # we're at user/address_books at the highest.
  scope :path => :user do
    resources :address_books do
      resources :contacts
    end
  end

  root :to => 'control_panel#index'
end
