require 'spec_helper'

describe ContactsController do
  always_login_user_1

  before (:each) do
    @address_book = AddressBook.make!(:address_book1)
  end

  describe "GET new" do
    it "should return successfully" do
      get :new, {:address_book_id => 1}
      response.should be_success
    end
  end
  
  describe "GET create" do
    pending "should return successfully" do
      get :create
      response.should be_success
    end
  end
  
  describe "GET edit" do
    it "should return successfully when given an id" do
      contact = Contact.make!(:contact1)
      get :edit, {:address_book_id => 1, :id => contact.to_param}
      response.should be_success
    end
  end
  
  describe "GET update" do
    pending "should return successfully" do
      get :new
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return successfully" do
      contact = Contact.make!(:contact1)
      get :show, {:address_book_id => 1, :id => contact.to_param}
      response.should be_success
    end
  end
end