module Carddav
  class BaseResource < DAV4Rack::Resource
    BASE_PROPERTIES = {
      'DAV:' => %w(
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