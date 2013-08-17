class Carddav::ContactController < Carddav::BaseController

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

    # If the body exceeds the quota, don't even bother trying to parse it.
    max_allowable_vcard_size = Meishi::Application.config.quota_max_vcard_size
    if (max_allowable_vcard_size > 0) and (request.content_length.to_i > max_allowable_vcard_size)
      if ENV['MEISHI_DEBUG_QUOTA'].to_i >= 1
        Rails.logger.debug "Attempt to exceed per vCard quota.  User: #{current_user.id}, request body size: #{request.content_length}, user agent: #{request.user_agent}"
      end
      raise Conflict
    end

    body = request.body.read

    # Ensure we only have one vcard per request per Section 5.1:
    # Address object resources contained in address book collections MUST
    # contain a single vCard component only.
    vcard_array = Vcard::Vcard.decode(body)

    raise BadRequest if vcard_array.size != 1

    vcard = vcard_array.first

    # Yeah, periods in the uid will break our routes.
    raise BadRequest if vcard.value('UID') =~ /\./

    # Check for If-None-Match: *
    # Section: 6.3.2
    # If set, client does not want to clobber; error if contact present
    want_new_contact = (request.env['HTTP_IF_NONE_MATCH'] == '*')

    # If the client has explicitly stated they want a new contact
    raise Conflict if (want_new_contact and resource.contact)

    resource.lock_check

    status = resource.put(request, response, vcard)

    response['Location'] = "#{scheme}://#{host}:#{port}#{url_format(resource)}" if status == Created
    response.body = response['Location']
    status

  end

end
