require 'spec_helper'

describe AddressBooksController do
  always_login_user_1

  before (:each) do
    @address_book1 = AddressBook.make!(:address_book1)
    @address_book2 = AddressBook.make!(:address_book2)
  end

  describe "GET new" do
    it "should return successfully" do
      get :new
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
    pending "should route correctly with no arguments" do
      should route(:get, :edit).to(:action => "edit")
    end

    it "should return a not found error when given no arguments" do
      # It would be nice to ensure that the user will see a 404
      # not a 500 or a stack trace.
      # response.should be_not_found

      expect { get :edit, {} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should return successfully when provided with an address book belonging to the current user" do
      get :edit, {:id => '1'}
      response.should be_success
    end

    it "should return forbidden when provided with an address book not belonging to the current user" do
      get :edit, {:id => '2'}
      response.should be_forbidden
    end

  end
  
  describe "GET update" do
    pending "should return successfully" do
      get :new
      response.should be_success
    end
  end

  describe "GET show" do
    it "should return a not found error when given no arguments" do
      expect { get :show, {} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should return successfully" do
      get :show, {:id => '1'}
      response.should be_success
    end
  end
end