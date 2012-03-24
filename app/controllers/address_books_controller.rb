class AddressBooksController < ApplicationController
  before_filter :check_permissions
  before_filter :require_address_book_object, :only => [:edit, :show]

  def new
    @address_book = AddressBook.new
    @address_book.user = current_user
  end

  def create
    @address_book = AddressBook.new(params[:address_book])
    @address_book.user = current_user
    if @address_book.save
      redirect_to(root_url, :notice => 'Address book succesfully created.')
    else
      render :action => 'new'
    end
  end

  def edit
  end
  
  def update
    if @address_book.update_attributes(params[:address_book])
      redirect_to(address_book_url(@address_book), :notice => 'Address book succesfully updated.')
    else
      render :address => 'edit'
    end
  end

  def show
  end

  private
  def check_permissions
    if params[:id]
      @address_book = AddressBook.find_by_id_and_user_id(params[:id], current_user.id)
    end

    if @address_book and @address_book.user.id != current_user.id
      render :status => :forbidden, :text => "Don't access another user's objects"
    end
  end
  def require_address_book_object
    raise ActiveRecord::RecordNotFound if @address_book.nil?
  end
end