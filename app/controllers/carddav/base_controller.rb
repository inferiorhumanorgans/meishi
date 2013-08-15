class Carddav::BaseController < DAV4Rack::Controller

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

  protected

  # Takes a block, gives it an xml builder with a DAV:error root element, and
  # will render the XML body and set an HTTP error code.  The HTTP status is
  # 403-Forbidden by default as per WebDAV's suggestions, alternatively, 409
  # a.k.a. Conflict is suggested for errors that are transient.  Any HTTPStatus
  # class will work.  Because this triggers an exception, it won't return.
  def xml_error(http_error_code=Forbidden, &block)
    render_xml(:error) do |xml|
      block.yield(xml)
    end
    raise http_error_code
  end

  def xpath_element(name, ns_uri=:dav)
    case ns_uri
    when :dav
      ns_uri = 'DAV:'
    when :carddav
      ns_uri = 'urn:ietf:params:xml:ns:carddav'
    end
    "*[local-name()='#{name}' and namespace-uri()='#{ns_uri}']"
  end

end
