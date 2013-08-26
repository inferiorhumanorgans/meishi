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

    @contact ||= Contact.new(address_book: @address_book, uid: vcf.value('UID'))

    raise BadRequest unless @contact.update_from_vcard_text(vcf)

    if @contact.save
      @public_path = URLHelpers.contact_path(@address_book.id, @contact.uid)
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
    Carddav::AddressBookResource.new(elements.first, elements.first, @request, @response, @options.merge(:user => @user))
  end

  def delete
    @contact.destroy
  end

  # Properties in alphabetical order
  protected

  prop :address_data, args: true do

    # If the client's specified a mime type, ensure that it's text/vcard or
    # text/vcard v3.0.  We don't support anything else. Yet.
    if (@attributes['content-type'].present? and @attributes['content-type'] != 'text/vcard') or
       (@attributes['content-type'] == 'text/vcard' and @attributes['version'].present? and @attributes['version'] != '3.0') or
       (!@attributes['content-type'].present? and @attributes['version'].present?)
      raise UnsupportedMediaType
    end

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

  prop :getcontentlength do
    @contact.to_s.size
  end

  prop :content_type do
    Mime::Type.lookup_by_extension(:vcf).to_s
  end

  prop :etag do
    @contact.etag
  end

  prop :getlastmodified do
    @contact.updated_at.httpdate
  end

  prop :resourcetype do
    s='<resourcetype></resourcetype>'
    Nokogiri::XML::DocumentFragment.parse(s)
  end

end
