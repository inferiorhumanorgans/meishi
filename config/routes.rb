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
  match '/' => redirect('/carddav/'), :via => [:propfind, :options]
  match '/principals/carddav' => redirect('/carddav/'), :via => [:propfind]
  ## END MacOSX 10.6 hacks 

  ## BEGIN RFC 6764
  match '/.well-known/carddav' => redirect('/carddav/'), :via => [:propfind]
  ## END RFC 6764

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
    ), :as => :contact

    match '/book/:book_id', :to => DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookResource,
      :controller_class => Carddav::AddressBookController
    ), :as => :book

    match '/book/', :to => DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookCollectionResource,
      :controller_class => Carddav::AddressBookCollectionController
    ), :as => :books
  end

  root :to => 'control_panel#index'
end