module Carddav
  class ContactResource < AddressBookBaseResource
    ALL_CARD_PROPERTIES = BaseResource::merge_properties(BaseResource::BASE_PROPERTIES, {
      'urn:ietf:params:xml:ns:carddav' => %w(address-data)
    })
    EXPLICIT_CARD_PROPERTIES = {}

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

    def put(request, response)
      b = request.body.read

      # TODO: Ensure we only have one vcard per request
      vcf = Vpim::Vcard.decode(b).first

      # Pull out all the fields we specify ourselves.
      contents = vcf.fields.select {|f| !(%w(BEGIN VERSION UID END).include? f.name) }

      uid = vcf.value('UID')

      # TODO: Check for If-None-Match
      # error if present, update/overwrite if not
      raise Conflict if Contact.find_by_uid(uid)

      @contact = Contact.new
      @contact.address_book = @address_book
      @contact.uid = uid
      contents.each do |f|
        @contact.fields.build(:name => f.name, :value => f.value)
      end
      
      if @contact.save
        response['Location'] = "/book/#{@address_book.id}/#{@contact.uid}"
        Created
      else
        # Is another error more appropriate?
        raise Conflict
      end
    end

    # Overload parent in this case because we want a different class (AddressBookResource)
    def parent
      Rails.logger.error "Contact::Parent FOR: #{@public_path}"
      elements = File.split(@public_path)
      return nil if (elements.first == '/book')
      AddressBookResource.new(elements.first, elements.first, @request, @response, @options.merge(:user => @user))
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
    
    def get_property(element)
      name = element[:name]
      namespace = element[:ns_href]

      unless (BaseResource::merge_properties(ALL_CARD_PROPERTIES, EXPLICIT_CARD_PROPERTIES))[namespace].include? name
        raise NotFound
      end

      case name
      when 'getetag'
        return '"%s-%d"' % [@contact.uid, @contact.updated_at.to_i]
      when 'address-data'
        s = '<C:address-data xmlns:C="urn:ietf:params:xml:ns:carddav"><![CDATA[%s]]></C:address-data>' % @contact.vcard.to_s
        return Nokogiri::XML::DocumentFragment.parse(s)
      end

      return super(element)
    end

    def content_type
      Mime::Type.lookup_by_extension(:vcf).to_s
    end

    def exist?
      Rails.logger.error "ContactR::exist?(#{public_path});"
      return true if Contact.find_by_uid(File.split(public_path).last)
      return false
    end
  end
end
