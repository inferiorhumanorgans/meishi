module Carddav
  class AddressBookResource < AddressBookBaseResource

    # The CardDAV spec requires that certain resources not be returned for an
    # allprop request.  It's nice to keep a list of all the properties we support
    # in the first place, so let's keep a separate list of the ones that need to
    # be explicitly requested.
    ALL_BOOK_PROPERTIES =  BaseResource::merge_properties(BaseResource::BASE_PROPERTIES, {
      'DAV:' => %w( current-user-privilege-set ),
      "urn:ietf:params:xml:ns:carddav" => %w(
        max-resource-size
        supported-address-data
        supported-report-set
      ),
      'http://calendarserver.org/ns/' => %w( getctag )
    })

    EXPLICIT_BOOK_PROPERTIES = {
      'urn:ietf:params:xml:ns:carddav' => %w(
        addressbook-description
        max-resource-size
        supported-collation-set
        supported-address-data
      )
    }

    def setup
      super
      @address_book = AddressBook.find_by_id_and_user_id(@book_path, current_user.id)
    end

    def exist?
      Rails.logger.error "ABR::exist?(#{public_path})"
      return !@address_book.nil?
    end

    def collection?
      true
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

      our_properties = (BaseResource::merge_properties(ALL_BOOK_PROPERTIES,EXPLICIT_BOOK_PROPERTIES))

      unless our_properties.include? namespace
        raise BadRequest
      end

      unless our_properties[namespace].include? name
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
      s='<D:current-user-privilege-set xmlns:D="DAV:">%s</D:current-user-privilege-set>'

      privileges_aggregate = privileges.inject('') do |ret, priv|
        ret << '<D:privilege><%s /></privilege>' % priv
      end

      s %= privileges_aggregate
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def displayname
      @address_book.name
    end

    def getctag
      s="<APPLE1:getctag xmlns:APPLE1='http://calendarserver.org/ns/'>#{@address_book.updated_at.to_i}</APPLE1:getctag>"
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def getetag
      '"None"'
    end

    # TODO: It would be more efficient to handle updating mtime with an after_update hook
    def last_modified
      ([@address_book.updated_at]+@address_book.contacts.collect{|c| c.updated_at}).max
    end

    # Limit vCards to 1k for now.
    # TODO: Enforce max-resource-size
    def max_resource_size
      1024
    end

    # For legibility let's underscore it and let the supeclass call it
    def resource_type
      s='<resourcetype><D:collection /><C:addressbook xmlns:C="urn:ietf:params:xml:ns:carddav"/></resourcetype>'
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def supported_address_data
      s=
      "<C:supported-address-data xmlns:C='urn:ietf:params:xml:ns:carddav'>
        <C:address-data-type content-type='text/vcard' version='3.0' />
       </C:supported-address-data>"
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