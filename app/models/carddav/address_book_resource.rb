module Carddav
  class AddressBookResource < AddressBookBaseResource

    # The CardDAV spec requires that certain resources not be returned for an
    # allprop request.  It's nice to keep a list of all the properties we support
    # in the first place, so let's keep a separate list of the ones that need to
    # be explicitly requested.
    ALL_BOOK_PROPERTIES = BaseResource::BASE_PROPERTIES + %w(
      current-user-privilege-set
      getctag
      max-resource-size
      supported-address-data
      supported-report-set
    )

    EXPLICIT_BOOK_PROPERTIES = %w(
      addressbook-description
      max-resource-size
      supported-collation-set
    )

    def setup
      super
      @address_book = AddressBook.find_by_id_and_user_id(@book_path, current_user.id)
    end

    def exist?
      Rails.logger.error "ABR::exist?(#{public_path})"
      return !@address_book.nil?
    end

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

    # Some properties shouldn't be included in an allprop request
    # but it's nice to do some sanity checking so keeping a list is good
    def property_names
      ALL_BOOK_PROPERTIES
    end

    def get_property(element)
      Rails.logger.error "AddressBook::get_book_property(#{element})"
      
      name = element[:name]
      namespace = element[:ns_href]

      unless BaseController::NAMESPACES.include?(namespace) and (ALL_BOOK_PROPERTIES+EXPLICIT_BOOK_PROPERTIES).include?(name)
        raise NotFound
      end

      # dav4rack aliases everything by default, so...
      fn = '_DAV_' + name.underscore
      return self.send(fn.to_sym) if self.respond_to? fn
      
      super(element)
    end

    ## Properties follow in alphabetical order

    def addressbook_description
      @address_book.name
    end

    def content_type
      # Not the right type, oh well
      Mime::Type.lookup_by_extension(:dir).to_s
    end

    def creation_date
      @address_book.created_at
    end

    def current_user_privilege_set
      privileges = %w(read write write-properties write-content read-acl read-current-user-privilege-set)
      s='<C:current-user-privilege-set>%s</C:current-user-privilege-set>'

      privileges_aggregate = privileges.inject('') do |ret, priv|
        ret << '<privilege>%s</privilege>' % priv
      end

      s %= privileges_aggregate
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def displayname
      @address_book.name
    end

    def getctag
      s="<x0:getctag xmlns:x0='http://calendarserver.org/ns/'>#{@address_book.updated_at.to_i}</x0:getctag>"
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def getetag
      '"None"'
    end

    # TODO: It would be more efficient to handle updating mtime with an after_update hook
    def last_modified
      ([@address_book.updated_at]+@address_book.contacts.collect{|c| c.updated_at}).max
    end

    def max_resource_size
      1024
    end

    # For legibility let's underscore it and let the supeclass call it
    def resource_type
      s='<resourcetype><D:collection /><C:addressbook xmlns:C="urn:ietf:params:xml:ns:carddav"/></resourcetype>'
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def supported_report_set
      reports = %w(addressbook-multiget addressbook-query)
      s = "<D:supported-report-set>%s</D:supported-report-set>"
      
      reports_aggregate = reports.inject('') do |ret, report|
        ret << '<D:report><%s /></D:report>' % report
      end
      
      s %= reports_aggregate
      Nokogiri::XML::DocumentFragment.parse(s)
    end
  end
end