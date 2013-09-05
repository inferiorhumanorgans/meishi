class Carddav::AddressBookCollectionResource < Carddav::AddressBookBaseResource

  def exist?
    Rails.logger.error "ABCR::exist?(#{public_path});"
    return true
  end

  def collection?
    true
  end

  def children
    Rails.logger.error "ABCR::children(#{public_path})"
    AddressBook.find_all_by_user_id(current_user.id).collect do |book|
      Rails.logger.error "trying to create this child (child should be AB): #{book.id.to_s}"
      child book.id.to_s
    end
  end

  protected

  def setup
    super
  end

  ## Properties follow in alphabetical order
  prop :creation_date do
    current_user.created_at
  end

  prop :displayname do
    "#{current_user.username}'s Meishi Address Book Collection"
  end

  prop :getlastmodified do
    address_book = AddressBook.where(user_id: current_user).order('updated_at DESC').first
    [current_user, address_book].compact.collect{|x| x.updated_at}.max.httpdate
  end

end
