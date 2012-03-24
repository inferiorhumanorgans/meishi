# https://github.com/plataformatec/devise/wiki/How-To:-Controllers-and-Views-tests-with-Rails-3-(and-rspec)
module ControllerMacros
  def login_user_1
    @request.env["devise.mapping"] = Devise.mappings[:password]
    user = User.make!(:user1)
    sign_in user
  end

  def always_login_user_1
    before(:each) do
      login_user_1
    end
  end
end