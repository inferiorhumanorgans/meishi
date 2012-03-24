require 'spec_helper'

describe ControlPanelController do
  describe "GET '/'" do
    it "should be forbidden if no users exist" do
      # Don't use an empty string here, rspec or devise doesn't like it. -_-
      get :index

      # With no users we should trip the "omg run the first_run rake task"
      response.should be_forbidden
    end

    it "should redirect if not logged in" do
      @user = User.make!(:user1)

      # Don't use an empty string here, rspec or devise doesn't like it. -_-
      get :index

      # We should redirect to the login page
      response.should be_redirect
    end

    it "should be successful if logged in" do
      login_user_1

      # Don't use an empty string here, rspec or devise doesn't like it. -_-
      get :index

      response.should be_success
    end
  end
end
