module Carddav
  class CardDavRootResource < Carddav::CardDavResource
    EXPLICIT_PROPERTIES = %w(addressbook-home-set principal-address addressbook-home-set)
    def collection?
      return true
    end

    def creation_date
      # Look up the current group and return that
      Time.now
    end

    def last_modified
      # Look up the current group and return the mtime of
      # the most recent child
      Time.now
    end

    def get_property(name)
      Rails.logger.error "CardDAVRoot::get_property(#{name})"
      s = nil
      case name
      when 'current-user-principal'
        s='<D:current-user-principal xmlns:D="DAV:"><D:href>/carddav/</D:href></D:current-user-principal>'
      when 'addressbook-home-set'
        s="<C:addressbook-home-set xmlns:C='urn:ietf:params:xml:ns:carddav'><D:href xmlns:D='DAV:'>/book/</D:href></C:addressbook-home-set>"
      when 'supported-report-set'
        s="<D:supported-report-set><D:report><addressbook-multiget /></D:report></D:supported-report-set>"
      end
      return Nokogiri::XML::DocumentFragment.parse(s) unless s.nil?
      super(name)
    end

    def exist?
      ret = false
      ret = true if path == ""
      STDERR.puts "*** CardDAVRoot::exist?(#{path}) = #{ret}"
      return ret
    end
  end
end