module Carddav
  class BaseResource < DAV4Rack::Resource
    BASE_PROPERTIES = {
      'DAV:' => %w(
        current-user-principal
        principal-URL
        creationdate
        displayname
        getlastmodified
        getetag
        resourcetype
        getcontenttype
        getcontentlength
      )}

    # Make OSX's AddressBook.app happy :(
    def setup
      @propstat_relative_path = true
      @root_xml_attributes = {'xmlns:C' => 'urn:ietf:params:xml:ns:carddav', 'xmlns:APPLE1' => 'http://calendarserver.org/ns/'}
    end

    def warden
      request.env['warden']
    end

    def current_user
      @current_user ||= warden.authenticate(:scope => :user)
      @current_user
    end
    
    def principal_url
      s="<D:principal-URL xmlns:D='DAV:'><D:href>/carddav/</D:href></D:principal-URL>"
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    # This violates the spec that requires an HTTP or HTTPS URL.  Unfortunately, Apple's
    # AddressBook.app treats everything as a pathname.  Also, the model shouldn't need to
    # know about the URL scheme and such.
    def current_user_principal
      s="<D:current-user-principal xmlns:D='DAV:'><D:href>/carddav/</D:href></D:current-user-principal>"
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    protected
    def self.merge_properties(all, explicit)
      ret = all.dup
      explicit.each do |key, value|
        ret[key] ||= []
        ret[key] += value
        ret[key].uniq!
      end
      ret
    end

  end
end