class Contact < ActiveRecord::Base
  belongs_to :address_book, :touch => true
  has_many :fields, :dependent => :destroy
  accepts_nested_attributes_for :fields, :reject_if => lambda { |f| f[:name].blank? or f[:value].blank?}, :allow_destroy => true

  before_validation :set_uid
  after_update :clear_vcard

  validates_presence_of :address_book, :uid

  def to_param
    self.uid
  end
  
  def vcard_raw
    data = ["BEGIN:VCARD", "VERSION:3.0"]
    has_ab_uid = false
    self.fields.each do |f|
      data.push ('%s:%s' % [f.name, f.value])
      has_ab_uid = true if (f.name == 'X-ABUID')
    end
    data.push "UID:%s" % self.uid
    data.push "X-ABUID:%s\\:ABPerson" % self.uid unless has_ab_uid
    data.push "END:VCARD"
    return data.join("\n")
  end
  
  def vcard
    @vcard ||= Vpim::Vcard.decode(vcard_raw).first
  end

  # This relies on FN existing, which it *SHOULD*
  # A quick SQL lookup is much faster than vcard parsing
  def quick_name
    self.fields.find(:first, :conditions => {:name => 'FN'}).value
  end
  
  def self.format_location (f)
    if f.respond_to? :capability
      if f.capability != %w(voice)
        return '%s %s' % [f.location.first, f.capability.join(', ')]
      end
    end
    f.location.first
  end
  
  private
  def clear_vcard
    @vard = nil
  end
  
  def set_uid
    self.uid ||= UUIDTools::UUID.random_create.to_s
  end
end