module Carddav
  class PrincipalResource < BaseResource

    ALL_PROPERTIES =  BaseResource::merge_properties(BaseResource::BASE_PROPERTIES, {
      'DAV:' => %w( current-user-privilege-set )
    })

    EXPLICIT_PROPERTIES = { 
      'urn:ietf:params:xml:ns:carddav' => %w(
        addressbook-home-set
        principal-address
      )
    }

    def exist?
      ret = false
      ret = true if path == ""
      STDERR.puts "*** Principal::exist?(#{path}) = #{ret}"
      return ret
    end

    def collection?
      return true
    end
    
    def children
      []
    end

    def get_property(element)
      Rails.logger.error "Principal::get_property(#{element[:namespace]}:#{element[:name]})"

      name = element[:name]
      namespace = element[:ns_href]

      our_properties = (BaseResource::merge_properties(ALL_PROPERTIES, EXPLICIT_PROPERTIES))
      
      unless our_properties.include? namespace
        raise BadRequest
      end

      unless our_properties[namespace].include?(name)
        raise NotFound
      end

      # dav4rack aliases everything by default... but only in the current class
      fn = '_DAV_' + name.underscore

      return self.send(fn.to_sym) if self.respond_to? fn
      return self.send(name.underscore.to_sym) if self.respond_to? name.underscore

      super(element)
    end

    ## Properties follow in alphabetical order

    # We should muck about in the routes and figure out the proper path
    def addressbook_home_set
      s="<C:addressbook-home-set xmlns:C='urn:ietf:params:xml:ns:carddav'><D:href xmlns:D='DAV:'>/book/</D:href></C:addressbook-home-set>"
      Nokogiri::XML::DocumentFragment.parse(s)
    end

    def creation_date
      # TODO: There's probably a more efficient way to grab the oldest ctime
      # Perhaps we should assume that the address book will never be newer than
      # any of its constituent contacts?
      contact_ids = AddressBook.find_all_by_user_id(current_user.id).collect{|ab| ab.contacts.collect{|c| c.id}}.flatten
      Field.first(:order => 'created_at ASC', :conditions => ['contact_id IN (?)', contact_ids]).created_at
    end

    def current_user_privilege_set
      privileges = %w(read read-acl read-current-user-privilege-set)
      s='<D:current-user-privilege-set xmlns:D="DAV:">%s</D:current-user-privilege-set>'

      privileges_aggregate = privileges.inject('') do |ret, priv|
        ret << '<D:privilege><%s /></privilege>' % priv
      end

      s %= privileges_aggregate
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

    def displayname
      "#{current_user.username}'s Principal Resource"
    end

    def last_modified
      contact_ids = AddressBook.find_all_by_user_id(current_user.id).collect{|ab| ab.contacts.collect{|c| c.id}}.flatten
      Field.first(:order => 'updated_at DESC', :conditions => ['contact_id IN (?)', contact_ids]).updated_at
    end

    # For legibility let's underscore it and let the supeclass call it
    def resource_type
      s='<resourcetype><D:collection /><D:principal/></resourcetype>'
      return Nokogiri::XML::DocumentFragment.parse(s)
    end

  end
end