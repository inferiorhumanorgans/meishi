# http://stackoverflow.com/questions/17409325/rails-4-include-rails-application-routes-url-helper-undefined-method-routes-for
module URLHelpers
  def self.included(base)
      @parent = base
  end

  def self.method_missing method, *args
      super unless @parent.methods.index method
      @parent.send(method, *args)
  end

  included Rails.application.routes.url_helpers
end
