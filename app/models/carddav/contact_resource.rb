class Carddav::ContactResource < Carddav::AddressBookBaseResource
  attr_accessor :contact

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

  def put(request, response, vcf)

    uid = vcf.value('UID')

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

    # Pull out all the fields we specify ourselves.
    contents = vcf.fields.select {|f| !(%w(BEGIN VERSION UID END).include? f.name) }
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
    @contact.destroy
  end

  # Properties in alphabetical order
  protected

  prop :address_data, args: true do
    if @children.empty?
      data = @contact.vcard.to_s
    else
      data = %w(BEGIN:VCARD)
      @children.each do |child|
        next if child[:name] != 'prop'
        name = child[:attributes]['name']
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
    Nokogiri::XML::DocumentFragment.parse(s)
  end

  prop :creation_date do
    @contact.created_at
  end

  prop :content_length do
    @contact.to_s.size
  end

  prop :content_type do
    Mime::Type.lookup_by_extension(:vcf).to_s
  end

  prop :etag do
    @contact.etag
  end

  prop :last_modified do
    @contact.updated_at
  end

end
