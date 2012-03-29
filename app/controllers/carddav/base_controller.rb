module Carddav

  class BaseController < DAV4Rack::Controller
    
    NAMESPACES = %w(urn:ietf:params:xml:ns:carddav DAV:)

    # TODO: Should really move towards inheriting from the proper rails classes
    # Anyhow the intent here is to ensure that the DAV header gets set for every
    # request under our purview.  Yes, a before_filter would be cleaner.
    # Apparently AddressBook.app will skip its OPTIONS request if it sees the DAV
    # header.  Neat.
    def initialize(request, response, options={})
      super
      @response["DAV"] = "1, 2, access-control, addressbook"
    end

    # Return response to OPTIONS
    def options
      @response["Allow"] = 'OPTIONS,HEAD,GET,PUT,POST,DELETE,PROPFIND,PROPPATCH,MKCOL,COPY,MOVE,LOCK,UNLOCK'
      OK
    end

  end

end