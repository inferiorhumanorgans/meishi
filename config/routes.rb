Meishi::Application.routes.draw do
  devise_for :users, :path => :user

  # Yeah, map this under the devise controller. Shouldn't conflict since
  # we're at user/address_books at the highest.
  scope :path => :user do
    resources :address_books do
      resources :contacts
    end
  end

  # TODO: Refactor these…
  match '/carddav/', :to => DAV4Rack::Handler.new(
    :root => '/carddav',
    :root_uri_path => '/carddav',
    :resource_class => Carddav::CardDavRootResource,
    :controller_class => CardDavBaseController
  ), :constraints => lambda {|r| r.env["force_http_auth"] = true; r.env["warden"].authenticate!}

  match '/book/:book_id/:card_id', :to => DAV4Rack::Handler.new(
    :root => '/book',
    :root_uri_path => '/book',
    :resource_class => Carddav::ContactResource,
    :controller_class => CardDavBaseController
  ), :constraints => lambda {|r| r.env["force_http_auth"] = true; r.env["warden"].authenticate!}

  match '/book/:book_id', :to => DAV4Rack::Handler.new(
    :root => '/book',
    :root_uri_path => '/book',
    :resource_class => Carddav::AddressBookResource,
    :controller_class => CardDavBaseController
  ), :constraints => lambda {|r| r.env["force_http_auth"] = true; r.env["warden"].authenticate!}

  match '/book/', :to => DAV4Rack::Handler.new(
    :root => '/book',
    :root_uri_path => '/book',
    :resource_class => Carddav::AddressBookCollectionResource,
    :controller_class => CardDavBaseController
  ), :constraints => lambda {|r| r.env["force_http_auth"] = true; r.env["warden"].authenticate!}

  root :to => 'control_panel#index'
end
