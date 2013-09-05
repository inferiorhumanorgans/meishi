require 'spec_helper'

describe Carddav::AddressBookController do

  include DAVControllerMacros

  always_login_user_1

  before(:each) do
    @controller = DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::ContactResource,
      :controller_class => Carddav::ContactController
    )

    User.make!(:user2)
    AddressBook.make!(:address_book1)
    AddressBook.make!(:address_book2)
    Contact.make!(:contact1)
    Contact.make!(:contact2)
    Contact.make!(:contact3)

    enable_debug_logging
  end

  describe "DELETE" do
    it "should fail on a bogus contact and return 404-not-found" do
      delete('/book/1/not-a-real-contact')
      response.status.should eq DAV4Rack::HTTPStatus::NotFound.code
    end

    it "should fail on someone else's contact and return 404-not-found" do
      contact = Contact.find(3)
      delete("/book/2/#{contact.uid}")
      response.status.should eq DAV4Rack::HTTPStatus::NotFound.code
    end

    it "should remove one of our contacts of our choosing" do
      contact = Contact.find(2)
      delete("/book/1/#{contact.uid}")
      response.status.should eq DAV4Rack::HTTPStatus::NoContent.code

      expect { Contact.find(2) }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end
end
