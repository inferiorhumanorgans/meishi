module Carddav
  class CardDavResource < DAV4Rack::Resource
    BASE_PROPERTIES = %w(creationdate displayname getlastmodified getetag resourcetype getcontenttype getcontentlength)

    def setup
      @fully_qualified = false
    end

    def warden
      request.env['warden']
    end

    def current_user
      @current_user ||= warden.authenticate(:scope => :user)
      @current_user
    end
  end
end