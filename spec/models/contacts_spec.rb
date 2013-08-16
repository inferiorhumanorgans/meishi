require 'spec_helper'

describe Contact do
  describe "static methods" do
    # Create a vcard with a voice and non voice telephone number
    # check text to make sure that voice doesn't get prepended,
    # but other types do

    it "should format a voice phone number correctly" do
      create_vcard1
      Contact.format_location(@vcard1.telephone).should eq 'home'
    end

    it "should format a non-voice phone number correctly" do
      create_vcard2
      Contact.format_location(@vcard2.telephone).should eq 'home fax'
    end

    it "should format an internet e-mail address correctly" do
      create_vcard1
      Contact.format_location(@vcard1.email).should eq 'home'
    end
  end
  
  describe "vcard handling" do
    it "should parse the fields into a valid vcard" do
      user = User.make!(:user1)
      address_book = AddressBook.make!(:address_book1)
      contact = Contact.make!(:contact1)
      contact.vcard.should be_kind_of(Vcard::Vcard)
    end
  end
end
