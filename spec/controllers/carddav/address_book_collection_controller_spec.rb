require 'spec_helper'

describe Carddav::BaseController do

  include DAVControllerMacros

  always_login_user_1

  before(:each) do
    @controller = DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookCollectionResource,
      :controller_class => Carddav::BaseController
    )

    AddressBook.make!(:address_book1)
    AddressBook.make!(:address_book2)
    Contact.make!(:contact1)
    Contact.make!(:contact2)

    enable_debug_logging
  end

  METHODS = %w(GET PUT POST DELETE PROPFIND PROPPATCH MKCOL COPY MOVE OPTIONS HEAD LOCK UNLOCK REPORT)
  METHODS.each do |method|
    define_method(method.downcase) do |*args|
      request(method, *args)
    end
  end

  describe "GET /book/" do
    it "should return a method-not-allowed failure" do
      get('/book/')
      response.status.should eq DAV4Rack::HTTPStatus::MethodNotAllowed.code
    end
  end

  describe "OPTIONS /book/" do
    it "should do its thing" do
      options('/book/')
      response.should be_ok
      response.headers.should include 'Allow'
    end
  end

  describe "PROPFIND books" do
    it "should treat an empty request as an allprop request" do
      propfind('/book/', 'HTTP_DEPTH' => 'infinity')
      response.body.length.should be > 0
    end
  end

end
