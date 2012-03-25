module Carddav
  class AddressBookResource < AddressBookBaseResource
    # The CardDAV spec requires that certain resources not be returned for an
    # allprop request.  It's nice to keep a list of all the properties we support
    # in the first place, so let's keep a separate list of the ones that need to
    # be explicitly requested.
    ALL_BOOK_PROPERTIES = CardDavResource::BASE_PROPERTIES + %w(getctag supported-address-data max-resource-size current-user-privilege-set)
    EXPLICIT_BOOK_PROPERTIES = %w(addressbook-description supported-collation-set max-resource-size)

    def collection?
      false
    end

    def children
      Rails.logger.error "ABR::children(#{public_path})"
      @address_book.contacts.collect do |c|
        Rails.logger.error "Trying to create this child (contact): #{c.uid.to_s}"
        child c.uid.to_s
      end
    end

    def setup
      super
      @address_book = AddressBook.find_by_id_and_user_id(@book_path, current_user.id)
    end

    # Some properties shouldn't be included in an allprop request
    # but it's nice to do some sanity checking so keeping a list is good
    def property_names
      ALL_BOOK_PROPERTIES
    end

    def creation_date
      @address_book.created_at
    end

    # TODO: It would probably be nicer to handle this in rails
    def last_modified
      ([@address_book.updated_at]+@address_book.contacts.collect{|c| c.updated_at}).max
    end

    def get_property(name)
      Rails.logger.error "AddressBook::get_book_property(#{name})"
      unless (ALL_BOOK_PROPERTIES+EXPLICIT_BOOK_PROPERTIES).include? name
        raise NotFound
      end

      case name
      when 'current-user-privilege-set'
        return current_privilege_set
      when 'resourcetype'
        return resource_type
      when 'max-resource-size'
        return 1024
      when 'addressbook-description'
        return @address_book.name
      when 'displayname'
        return @address_book.name
      when 'getctag'
        s="<x0:getctag xmlns:x0='http://calendarserver.org/ns/'>#{@address_book.updated_at.to_i}</x0:getctag>"
        return Nokogiri::XML::DocumentFragment.parse(s)
      when 'getetag'
        return '"None"'
      end
      return super(name)
    end

    def current_privilege_set
      privileges = %w(read write write-properties write-content read-acl read-current-user-privilege-set)

      priv_string = privileges.inject('') do |ret, priv|
        ret << '<privilege>%s</privilege>' % priv
      end

      s='<C:current-user-privilege-set>%s</C:current-user-privilege-set>' % priv_string
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def resource_type
      s='<resourcetype><D:collection /><C:addressbook xmlns:C="urn:ietf:params:xml:ns:carddav"/></resourcetype>'
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def content_type
      # Not the right type, oh well
      Mime::Type.lookup_by_extension(:txt).to_s
    end

    def exist?
      Rails.logger.error "ABR::exist?(#{public_path})"
      return !@address_book.nil?
    end
  end
end