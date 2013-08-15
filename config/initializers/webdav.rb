require 'time'
require 'uri'
require 'devise/strategies/database_authenticatable'

class HTTPAuthFailureApp < Devise::FailureApp
  def respond
    http_auth
  end
  def http_auth_header?
    true
  end
end

# Gross patch to force HTTP auth when we want it
class Devise::Delegator
  def failure_app(env)
    app = env["warden.options"] &&
      (scope = env["warden.options"][:scope]) &&
      Devise.mappings[scope.to_sym].failure_app
    if (env["force_http_auth"] == true)
      app = HTTPAuthFailureApp
    end
    app || Devise::FailureApp
  end
end
