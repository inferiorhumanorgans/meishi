class ContactsController < ApplicationController
  before_filter :check_permissions

  DEFAULT_FIELDS = %w(FN N TEL;TYPE=voice,home EMAIL;TYPE=internet,work)

  def new
    @contact = Contact.new
    DEFAULT_FIELDS.each do |f|
      @contact.fields.build({:name => f})
    end
  end
  
  # TODO: Validate the vcard data (ensure that names are specified)
  # TODO: Calculate FN from N?
  def create
    @contact = Contact.new(params[:contact])
    @contact.address_book = @address_book

    if @contact.save
      redirect_to(address_book_url(@address_book), :notice => 'Contact succesfully added to address book.')
    else
      render :action => 'new'
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.vcf  { render :text => @contact.vcard_raw }
      format.text { render :text => @contact.vcard_raw }
    end
  end

  def edit
  end
  
  # TODO: Validate the vcard data w/ Vpim::Vcard.decode?
  def update
    if @contact.update_attributes(params[:contact])
      redirect_to(address_book_contact_url(@address_book, @contact), :notice => 'Contact succesfully updated.')
    else
      render :address => 'edit'
    end
  end

  private
  def check_permissions
    @address_book = AddressBook.find_by_id_and_user_id(params[:address_book_id], current_user.id) || not_found

    if @address_book.user.id != current_user.id
      render :status => :forbidden, :text => "Don't access another user's objects"
    end

    if params[:id]
      @contact = Contact.find_by_uid_and_address_book_id(params[:id], @address_book.id) || not_found
    end
  end
end