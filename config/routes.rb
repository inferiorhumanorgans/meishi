Meishi::Application.routes.draw do
  devise_for :users, :path => :user

  # Yeah, map this under the devise controller. Shouldn't conflict since
  # we're at user/address_books at the highest.
  scope :path => :user do
    resources :address_books do
      resources :contacts
    end
  end
  
  get '/book/:address_book_id/:id(.:format)' => 'contacts#show', :defaults => {:format => :vcf}

  ## BEGIN MacOSX 10.6 hacks
  match '/' => redirect('/carddav/'), :via => [:propfind]
  match '/principals/carddav' => redirect('/carddav/'), :via => [:propfind]
  ## END MacOSX 10.6 hacks 

  # TODO: Refactor these…
  constraints(ForceHTTPAuthConstraint) do
    match '/carddav/', :to => DAV4Rack::Handler.new(
      :root => '/carddav',
      :root_uri_path => '/carddav',
      :resource_class => Carddav::PrincipalResource,
      :controller_class => Carddav::BaseController
    ), :as => :principal

    match '/book/:book_id/:card_id', :to => DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::ContactResource,
      :controller_class => Carddav::ContactController
    )

    match '/book/:book_id', :to => DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookResource,
      :controller_class => Carddav::AddressBookController
    )

    match '/book/', :to => DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookCollectionResource,
      :controller_class => Carddav::BaseController
    )
  end

  root :to => 'control_panel#index'
end