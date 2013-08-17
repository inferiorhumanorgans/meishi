class Carddav::BaseController < DAV4Rack::Controller

  NAMESPACES = %w(urn:ietf:params:xml:ns:carddav DAV:)

  # Flags for to_xml for use with XML debugging/logging.  This will compact everything.
  NO_INDENT_FLAGS = {save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION}
  # Flags for to_xml for use with XML debugging/logging.  This will pretty print things.
  YES_INDENT_FLAGS = {save_with: Nokogiri::XML::Node::SaveOptions::FORMAT | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION, indent: 2}

  # Constructor.
  # @param [Rack::Request] request
  # @param [Rack::Response] response
  # @param [Hash] options
  # The intent here is to ensure that the DAV header gets set for every
  # request under our purview.  Yes, a before_filter would be cleaner.
  # Apparently AddressBook.app will skip its OPTIONS request if it sees the DAV
  # header.  Neat.
  def initialize(request, response, options={})
    super
    @response["DAV"] = "1, 2, access-control, addressbook"
    @response['Access-Control-Allow-Origin'] = '*' if Meishi::Application.config.permissive_cross_domain_policy == true
  end

  # Default OPTIONS handler.
  # @return [DAV4Rack::HTTPStatus]
  def options
    @response["Allow"] = 'OPTIONS,HEAD,GET,PUT,POST,DELETE,PROPFIND,PROPPATCH,MKCOL,COPY,MOVE,LOCK,UNLOCK'
    OK
  end

  # Default PROPFIND handler.  The only difference from the DAV4Rack handler
  # is that we have some extra logging bits tacked onto the end.  The
  # following environment variables control the logging:
  # - MEISHI_DEBUG_XML_REQUEST If >=1 log the XML request. If >= 2 pretty print it.
  # - MEISHI_DEBUG_XML_RESPONSE If >=1 log the XML response. If >= 2 pretty print it.
  def propfind
    super

    debug_request = ENV['MEISHI_DEBUG_XML_REQUEST'].to_i
    if debug_request >= 1
      Rails.logger.debug "*** REQUEST BEGIN"
      Rails.logger.debug request_document.to_xml((debug_request >= 2) ? YES_INDENT_FLAGS : NO_INDENT_FLAGS)
      Rails.logger.debug "*** REQUEST END"
    end

    debug_response = ENV['MEISHI_DEBUG_XML_RESPONSE'].to_i
    if debug_response >= 1
      Rails.logger.debug "*** RESPONSE BEGIN"
      x = Nokogiri::XML(response.body) do |config|
        config.default_xml.noblanks
      end

      Rails.logger.debug x.to_xml((debug_response >= 2) ? YES_INDENT_FLAGS : NO_INDENT_FLAGS)

      Rails.logger.debug "*** RESPONSE END"
    end
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

  # Returns the warden authentication object
  def warden
    request.env['warden']
  end

  def current_user
    @current_user ||= warden.authenticate(:scope => :user)
  end
end
