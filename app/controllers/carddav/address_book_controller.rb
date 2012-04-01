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

      c_ns = ns('urn:ietf:params:xml:ns:carddav')

      props = request_document.xpath("/#{c_ns}addressbook-multiget/#{ns}prop").children.find_all{|n| n.element?}.map{|n|
        {:name => n.name, :namespace => n.namespace.prefix, :ns_href => n.namespace.href}
      }
      hrefs = request_document.xpath("/#{c_ns}addressbook-multiget/#{ns}href").collect{|n| 
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
            if resource.public_path == _href
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