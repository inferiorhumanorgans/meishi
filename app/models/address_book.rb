class AddressBook < ActiveRecord::Base
  belongs_to :user
  has_many :contacts, :dependent => :destroy

  attr_accessible :name
  
  validates_presence_of :name
end