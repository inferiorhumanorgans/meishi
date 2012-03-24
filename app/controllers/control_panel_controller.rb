class ControlPanelController < ApplicationController
  def index
    @address_books = AddressBook.find_all_by_user_id(current_user)
  end
end