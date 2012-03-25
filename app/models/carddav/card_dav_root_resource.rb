module Carddav
  class CardDavRootResource < Carddav::CardDavResource
    EXPLICIT_PROPERTIES = %w(addressbook-home-set principal-address addressbook-home-set)
    def collection?
      return true
    end

    def creation_date
      # TODO: Old habits die hard, there's probably a nicer way to do this
      contact_ids = AddressBook.find_all_by_user_id(1).collect{|ab| ab.contacts.collect{|c| c.id}}.flatten
      Field.first(:order => 'created_at ASC', :conditions => ['contact_id IN (?)', contact_ids]).created_at
    end

    def last_modified
      contact_ids = AddressBook.find_all_by_user_id(1).collect{|ab| ab.contacts.collect{|c| c.id}}.flatten
      Field.first(:order => 'updated_at DESC', :conditions => ['contact_id IN (?)', contact_ids]).updated_at
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