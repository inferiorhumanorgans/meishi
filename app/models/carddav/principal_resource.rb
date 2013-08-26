class Carddav::PrincipalResource < Carddav::BaseResource

  ALL_PROPERTIES =  {}

  EXPLICIT_PROPERTIES = { 
    'DAV:' => %w(
      alternate-URI-set
      group-member-set
      group-membership
    ),
    'urn:ietf:params:xml:ns:carddav' => %w(
      addressbook-home-set
      principal-address
    )
  }

  def exist?
    ret = (path == '')
    return ret
  end

  def collection?
    return true
  end
  
  ## Properties follow in alphabetical order
  protected

  # We should muck about in the routes and figure out the proper path
  prop :addressbook_home_set do
    s="<C:addressbook-home-set xmlns:C='urn:ietf:params:xml:ns:carddav'><D:href xmlns:D='DAV:'>#{url_or_path(:books, trailing_slash: true)}</D:href></C:addressbook-home-set>"
    Nokogiri::XML::DocumentFragment.parse(s)
  end

  prop :alternate_uri_set do
    s="<D:alternate-URI-set xmlns:D='DAV:' />"
    Nokogiri::XML::DocumentFragment.parse(s)
  end

  prop :creation_date do
    # It stands to reason that there won't be anything older than AddressBook
    # since contacts and their fields are dependent upon an AddressBook
    oldest_addressbook = AddressBook.where(user_id: current_user.id).order('created_at ASC').first
    raise NotFound unless oldest_addressbook
    oldest_addressbook.created_at
  end

  prop :displayname do
    "#{current_user.username}'s Principal Resource"
  end

  prop :group_membership do
    s="<D:group-membership xmlns:D='DAV:' />"
    Nokogiri::XML::DocumentFragment.parse(s)
  end

  prop :group_membership_set do
    s="<D:group-membership-set xmlns:D='DAV:' />"
    Nokogiri::XML::DocumentFragment.parse(s)
  end

  prop :last_modified do
    AddressBook.where(user_id: current_user.id).order('updated_at DESC').first.updated_at
  end

  # For legibility let's underscore it and let the supeclass call it
  prop :resource_type do
    s='<resourcetype><D:collection /><D:principal/></resourcetype>'
    Nokogiri::XML::DocumentFragment.parse(s)
  end

end
