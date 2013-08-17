=begin
RFC 4918
16. Precondition/Postcondition XML Elements
  In a 207 Multi-Status response, the XML element
  MUST appear inside an 'error' element in the appropriate 'propstat or
  'response' element depending on whether the condition applies to one
  or more properties or to the resource as a whole.  In all other error
  responses where this specification's 'error' body is used, the
  precondition/postcondition XML element MUST be returned as the child
  of a top-level 'error' element in the response body, unless otherwise
  negotiated by the request, along with an appropriate response status.
  The most common response status codes are 403 (Forbidden) if the
  request should not be repeated because it will always fail, and 409
  (Conflict) if it is expected that the user might be able to resolve
  the conflict and resubmit the request.  The 'error' element MAY
  contain child elements with specific error information and MAY be
  extended with any custom child elements.
=end

=begin
RFC 3253
3.6 REPORT Method
  Preconditions:

    (DAV:supported-report): The specified report MUST be supported by
    the resource identified by the request-URL.
=end

=begin
RFC 6352
8.7. CARDDAV:addressbook-multiget Report
  Preconditions:

    (CARDDAV:supported-address-data): The attributes "content-type"
    and "version" of the CARDDAV:address-data XML elements (see
    Section 10.4) specify a media type supported by the server for
    address object resources.
=end
class Carddav::AddressBookController < Carddav::BaseController

  def report
    debug_report = ENV['MEISHI_DEBUG_REPORT'].to_i

    unless resource.exist?
      return NotFound
    end

    Rails.logger.debug "REPORT DEPTH IS: #{depth.inspect}" if debug_report >= 1

    if request_document.nil? or request_document.root.nil?
      xml_error(BadRequest) do |err|
        err.send :'empty-request'
      end
    end

    Rails.logger.debug "REPORT type: #{request_document.root.name}" if debug_report >= 1
    case request_document.root.name
    when 'addressbook-multiget'
      addressbook_multiget
    else
      xml_error do |err|
        err.send :'supported-report'
      end
    end

  end

  protected
  def addressbook_multiget
    debug_multiget = ENV['MEISHI_DEBUG_REPORT_LIST'] =~ /multiget/

    # TODO: Include a DAV:error response
    # CardDAV §8.7 clearly states Depth must equal zero for this report
    # But Apple's AddressBook.app (OSX 10.6) sets the depth to infinity anyhow.
    infinity_ok = Quirks.match(:INFINITE_ADDRESS_BOOK_MULTIGET, request.env['HTTP_USER_AGENT'])

    unless (depth == 0) or (depth == :infinity and infinity_ok)
      xml_error(BadRequest) do |err|
        err.send :'invalid-depth'
      end
    end

    props = request_document.xpath("/#{xpath_element('addressbook-multiget', :carddav)}/#{xpath_element('prop')}").children.find_all{|n| n.element?}.map{|n|
      to_element_hash(n)
    }
    # Handle the address-data element
    # - Check for child properties (vCard fields)
    # - Check for mime-type and version.  If present they must match vCard 3.0 for now since we don't support anything else.
    hrefs = request_document.xpath("/#{xpath_element('addressbook-multiget', :carddav)}/#{xpath_element('href')}").collect{|n| 
      text = n.text
      # TODO: Make sure that the hrefs passed into the report are either paths or fully qualified URLs with the right host+protocol+port prefix
      path = URI.parse(text).path
      Rails.logger.debug "Scanned this HREF: #{text} PATH: #{path}" if debug_multiget
      text
    }.compact
    
    if hrefs.empty?
      xml_error(BadRequest) do |err|
        err.send :'href-missing'
      end
    end

    multistatus do |xml|
      hrefs.each do |_href|
        xml.response do
          xml.href _href

          path = File.split(URI.parse(_href).path).last
          Rails.logger.error "Creating child w/ ORIG=#{resource.public_path} HREF=#{_href} FILE=#{path}!"

          # TODO: Write a test to cover asking for a report expecting contact objects but given an address book path
          # Yes, CardDAVMate does this.
          cur_resource = resource.is_self?(_href) ? resource : resource.child(File.split(path).last)
          
          if cur_resource.exist?
            propstats(xml, get_properties(cur_resource, props))
          else
            xml.status "#{http_version} #{NotFound.status_line}"
          end

        end
      end
    end
  end

end
