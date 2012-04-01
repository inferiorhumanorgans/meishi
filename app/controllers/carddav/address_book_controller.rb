module Carddav

  class AddressBookController < BaseController

    def report
      unless resource.exist?
        return NotFound
      end

      Rails.logger.error "REPORT XML REQUEST:\n#{request_document.to_xml}"
      case request_document.root.name
      when 'addressbook-multiget'
        addressbook_multiget
      else
        NotImplemented
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