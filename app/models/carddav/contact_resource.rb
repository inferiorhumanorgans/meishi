module Carddav
  class ContactResource < AddressBookBaseResource
    ALL_PROPERTIES = {
      'urn:ietf:params:xml:ns:carddav' => %w(address-data)
    }

    EXPLICIT_PROPERTIES = {}

    def collection?
      false
    end

    def exist?
      Rails.logger.error "ContactR::exist?(#{public_path});"
      return true if Contact.find_by_uid(File.split(public_path).last)
      return false
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

      # Ensure we only have one vcard per request
      # Section 5.1:
      # Address object resources contained in address book collections MUST
      # contain a single vCard component only.
      vcard_array = Vcard::Vcard.decode(b)
      raise BadRequest if vcard_array.size != 1
      vcf = vcard_array.first

      # Pull out all the fields we specify ourselves.
      contents = vcf.fields.select {|f| !(%w(BEGIN VERSION UID END).include? f.name) }

      uid = vcf.value('UID')
      
      raise BadRequest if uid =~ /\./ # Yeah, this'll break our routes.

      # Check for If-None-Match: *
      # Section: 6.3.2
      # If set, client does not want to clobber; error if contact present
      want_new_contact = (request.env['HTTP_IF_NONE_MATCH'] == '*')

      @contact = Contact.find_by_uid(uid)

      # If the client has explicitly stated they want a new contact
      raise Conflict if (want_new_contact and @contact)

      # Otherwise let's update it
      @contact.fields.clear if @contact

      @contact ||= Contact.new

      @contact.address_book = @address_book
      @contact.uid = uid
      contents.each do |f|
        @contact.fields.build(:name => f.name, :value => f.value)
      end

      # This is gross.  SoGo sometimes sends out vCard data w/o the mandatory N field
      # And Vpim gobbles up the FN field so it's inaccessible directly
      if vcf.value('N').nil? or vcf.value('N').fullname.empty?
        raise BadRequest
      end

      if @contact.save
        @public_path = "/book/#{@address_book.id}/#{@contact.uid}"
        response['ETag'] = @contact.etag
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

    def delete
      # TODO: Proper authorization, is this OUR contact?
      @contact.destroy
      NoContent
    end

    # Properties in alphabetical order
    protected

    def address_data(attributes={}, fields=[])
      if fields.empty?
        data = @contact.vcard.to_s
      else
        data = %w(BEGIN:VCARD)
        fields.each do |f|
          next if f[:name] != 'prop'
          name = f[:attributes]['name']
          case name.upcase
          when 'VERSION'
            data << 'VERSION:3.0'
          when 'UID'
            data << 'UID:%s' % @contact.uid
          else
            field = @contact.vcard.field(name)
            data << field.to_s.strip unless field.nil?
          end
        end
        data << 'END:VCARD'
        data = data.compact.join("\n")
      end
      s = '<C:address-data xmlns:C="urn:ietf:params:xml:ns:carddav"><![CDATA[%s]]></C:address-data>' % data
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def creation_date
      @contact.created_at
    end

    def content_length
      @contact.to_s.size
    end

    def content_type
      Mime::Type.lookup_by_extension(:vcf).to_s
    end

    def etag
      @contact.etag
    end

    def last_modified
      @contact.updated_at
    end

  end
end
