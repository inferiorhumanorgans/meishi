module Carddav
  class ContactResource < AddressBookBaseResource
    ALL_CARD_PROPERTIES = CardDavResource::BASE_PROPERTIES + %w(address-data)
    EXPLICIT_CARD_PROPERTIES = %w(supported-collation-set supported-address-data)

    def collection?
      false
    end

    def setup
      super

      @address_book = AddressBook.find_by_id_and_user_id(@book_path, current_user.id)

      path_str = @public_path.dup

      @address_book = AddressBook.find_by_id_and_user_id(@book_path, current_user.id)

      uid = File.split(path_str).last
      @contact = Contact.find_by_uid_and_address_book_id(uid, @address_book.id)
    end

    # Some properties shouldn't be included in an allprop request
    # but it's nice to do some sanity checking so keeping a list is good
    def property_names
      ALL_CARD_PROPERTIES
    end

    def creation_date
      @contact.created_at
    end

    def last_modified
      @contact.updated_at
    end

    def get_property(name)
      Rails.logger.error "AddressBook::get_contact_property(#{name})"
      unless (ALL_CARD_PROPERTIES+EXPLICIT_CARD_PROPERTIES).include? name
        raise NotFound
      end

      case name
      when 'getetag'
        return '"%s-%d"' % [@contact.uid, @contact.updated_at.to_i]
      when 'address-data'
        s = '<C:address-data xmlns:C="urn:ietf:params:xml:ns:carddav"><![CDATA[%s]]></C:address-data>' % @contact.vcard.to_s
        return Nokogiri::XML::DocumentFragment.parse(s)
      end

      return super(name)
    end

    def content_type
      Mime::Type.lookup_by_extension(:vcf).to_s
    end

    def exist?
      Rails.logger.error "ContactR::exist?(#{public_path});"
      return true if Contact.find(File.split(public_path).last)
      return false
    end
  end
end