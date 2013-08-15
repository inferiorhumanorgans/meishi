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

end
