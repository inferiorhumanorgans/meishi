module Carddav
  class AddressBookResource < AddressBookBaseResource

    # The CardDAV spec requires that certain resources not be returned for an
    # allprop request.  It's nice to keep a list of all the properties we support
    # in the first place, so let's keep a separate list of the ones that need to
    # be explicitly requested.
    ALL_PROPERTIES =  {
      'DAV:' => %w(
        current-user-privilege-set
        supported-report-set
      ),
      "urn:ietf:params:xml:ns:carddav" => %w(
        max-resource-size
        supported-address-data
      ),
      'http://calendarserver.org/ns/' => %w( getctag )
    }

    EXPLICIT_PROPERTIES = {
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
      !@address_book.nil?
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
    
    ## Properties follow in alphabetical order
    protected

    prop :addressbook_description do
      @address_book.name
    end

    prop :content_type do
      # Not the right type, oh well
      Mime::Type.lookup_by_extension(:dir).to_s
    end

    prop :creation_date do
      @address_book.created_at
    end

    prop :current_user_privilege_set do
      privileges = %w(read write write-properties write-content read-acl read-current-user-privilege-set)
      s='<D:current-user-privilege-set xmlns:D="DAV:">%s</D:current-user-privilege-set>'

      privileges_aggregate = privileges.inject('') do |ret, priv|
        ret << '<D:privilege><%s /></privilege>' % priv
      end

      s %= privileges_aggregate

      Nokogiri::XML::DocumentFragment.parse(s)
    end

    prop :displayname do
      @address_book.name
    end

    prop :getctag do
      s="<APPLE1:getctag xmlns:APPLE1='http://calendarserver.org/ns/'>#{@address_book.updated_at.to_i}</APPLE1:getctag>"
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    prop :getetag do
      '"None"'
    end

    # TODO: It would be more efficient to handle updating mtime with an after_update hook
    prop :last_modified do
      ([@address_book.updated_at]+@address_book.contacts.collect{|c| c.updated_at}).max
    end

    # Limit vCards to 1k for now.
    # TODO: Enforce max-resource-size
    prop :max_resource_size do
      1024
    end

    # For legibility let's underscore it and let the supeclass call it
    prop :resource_type do
      s='<resourcetype><D:collection /><C:addressbook xmlns:C="urn:ietf:params:xml:ns:carddav"/></resourcetype>'
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    prop :supported_address_data do
      s=
      "<C:supported-address-data xmlns:C='urn:ietf:params:xml:ns:carddav'>
        <C:address-data-type content-type='text/vcard' version='3.0' />
       </C:supported-address-data>"
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    prop :supported_report_set do
      reports = %w(addressbook-multiget addressbook-query)
      s = "<D:supported-report-set>%s</D:supported-report-set>"
      
      reports_aggregate = reports.inject('') do |ret, report|
        ret << "<D:report><C:%s xmlns:C='urn:ietf:params:xml:ns:carddav'/></D:report>" % report
      end
      
      s %= reports_aggregate
      Nokogiri::XML::DocumentFragment.parse(s)
    end
  end
end
