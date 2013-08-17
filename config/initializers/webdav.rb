require 'time'
require 'uri'
require 'devise/strategies/database_authenticatable'

class HTTPAuthFailureApp < Devise::FailureApp
  def respond

    # http://www.inf-it.com/mlmmj/davclients/2013-05/0000043.html
    if Meishi::Application.config.permissive_cross_domain_policy == true
      self.headers['Access-Control-Allow-Origin'] = '*'
      self.headers['Access-Control-Allow-Methods'] = %w(OPTIONS GET HEAD POST PUT DELETE PROPFIND PROPPATCH REPORT LOCK UNLOCK).join(',')
      self.headers['Access-Control-Allow-Headers'] = %w(User-Agent Authorization Content-type Depth If-match If-None-Match Lock-Token Timeout Destination Overwrite X-client X-Requested-With).join(',')
    end

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
