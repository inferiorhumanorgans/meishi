class Field < ActiveRecord::Base
  belongs_to :contact, :touch => true

  validates_presence_of :name, :value

  # FN = Full Name
  # N = Family Name;Given Name;Additional Names;Honorific Prefixes;Honorific Suffixes
  # TEL = TYPE=foo:number
  #   TYPES =
  #   home,work
  #   msg for messaging support
  #   pref for preferred
  #   voice/fax/cell/video/pager/bbs/modem/car/isdn/pcs (default = voice)
end