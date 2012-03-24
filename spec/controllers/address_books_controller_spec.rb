require 'spec_helper'

describe AddressBooksController do
  always_login_user_1

  before (:each) do
    @address_book = AddressBook.make!(:address_book1)
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
      get :edit, {}
      response.should be_not_found
    end

    it "should return successfully with arguments" do
      get :edit, {:id => '1'}
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
    it "should return a not found error when given no arguments" do
      get :show, {}
      response.should be_not_found
    end

    it "should return successfully" do
      get :show, {:id => '1'}
      response.should be_success
    end
  end
end