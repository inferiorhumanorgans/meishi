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
module Carddav

  class AddressBookController < BaseController

    def report
      unless resource.exist?
        return NotFound
      end

      Rails.logger.error "REPORT XML REQUEST:\n#{request_document.to_xml}"
      Rails.logger.error "REPORT DEPTH IS: #{depth.inspect}"

      if request_document.nil? or request_document.root.nil?
        render_xml(:error) do |xml|
          xml.send :'empty-request'
        end
        return BadRequest
      end

      case request_document.root.name
      when 'addressbook-multiget'
        addressbook_multiget
      else
        render_xml(:error) do |xml|
          xml.send :'supported-report'
        end
        Forbidden
      end

    end

    protected
    def addressbook_multiget
      Rails.logger.error "REPORT addressbook-multiget"

      props = request_document.xpath("/#{xpath_element('addressbook-multiget', :carddav)}/#{xpath_element('prop')}").children.find_all{|n| n.element?}.map{|n|
        {:name => n.name, :namespace => n.namespace.prefix, :ns_href => n.namespace.href}
      }
      hrefs = request_document.xpath("/#{xpath_element('addressbook-multiget', :carddav)}/#{xpath_element('href')}").collect{|n| 
        text = n.text
        path = URI.parse(text).path
        Rails.logger.error "Scanned this HREF: #{text} PATH: #{path}"
        text
      }.compact

      multistatus do |xml|
        hrefs.each do |_href|
          xml.response do
            xml.href _href

            path = File.split(URI.parse(_href).path).last
            Rails.logger.error "Creating child w/ ORIG=#{resource.public_path} HREF=#{_href} FILE=#{path}!"

            # TODO: Write a test to cover asking for a report expecting contact objects but given an address book path
            # Yes, CardDAVMate does this.
            if resource.is_self? _href
              propstats(xml, get_properties(resource, props))
            else
              propstats(xml, get_properties(resource.child(File.split(path).last), props))
            end
          end
        end
      end
    end

  end

end
