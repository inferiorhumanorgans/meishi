class Contact < ActiveRecord::Base
  belongs_to :address_book
  has_many :fields, :dependent => :destroy
  accepts_nested_attributes_for :fields, :reject_if => lambda { |f| f[:name].blank? or f[:value].blank?}, :allow_destroy => true
   VCARD_FORMAT = "BEGIN:VCARD\nVERSION:3.0\n%s\nEND:VCARD"

  after_update :clear_vcard

  validates_presence_of :address_book, :uid

  def to_param
    self.uid
  end
  
  def vcard_raw
    data = ["BEGIN:VCARD", "VERSION:3.0"]
    self.fields.each do |f|
      data.push ('%s:%s' % [f.name, f.value])
    end
    data.push "UID:%s" % self.uid
    data.push "X-AB-UID:%s:ABPerson" % self.uid
    data.push "END:VCARD"
    return data.join("\n")
  end
  
  def vcard
    @vcard ||= Vpim::Vcard.decode(vcard_raw).first
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
end