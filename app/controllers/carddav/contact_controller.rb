class Carddav::ContactController < DAV4Rack::Controller

  def delete
    raise NotFound unless resource.exist?
    
    resource.lock_check

    unless resource.contact.address_book.user.id == current_user.id
      raise Forbidden
    end

    resource.delete

    NoContent
  end

  def put
    raise Forbidden if resource.collection?
      
    raise Conflict if !resource.parent_exists? or !resource.parent.collection?

    body = request.body.read

    # Ensure we only have one vcard per request
    # Section 5.1:
    # Address object resources contained in address book collections MUST
    # contain a single vCard component only.
    vcard_array = Vcard::Vcard.decode(body)

    raise BadRequest if vcard_array.size != 1

    vcard = vcard_array.first

    # Yeah, periods in the uid will break our routes.
    raise BadRequest if vcard.value('UID') =~ /\./

    resource.lock_check

    status = resource.put(request, response, vcard)

    response['Location'] = "#{scheme}://#{host}:#{port}#{url_format(resource)}" if status == Created
    response.body = response['Location']
    status

  end

end
