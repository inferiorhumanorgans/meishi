class Field < ActiveRecord::Base
  belongs_to :contact, :touch => true
  has_one :address_book, :through => :contact

  validates_presence_of :name, :value

  before_save :normalize_for_collation

  def normalize_for_collation
    self.unicode_casemap = Comparators::UnicodeCasemap.prepare(self.value)
    self.ascii_casemap = Comparators::ASCIICasemap.prepare(self.value)

    return true
  end

  # FN = Full Name
  # N = Family Name;Given Name;Additional Names;Honorific Prefixes;Honorific Suffixes
  # TEL = TYPE=foo:number
  #   TYPES =
  #   home,work
  #   msg for messaging support
  #   pref for preferred
  #   voice/fax/cell/video/pager/bbs/modem/car/isdn/pcs (default = voice)
end
