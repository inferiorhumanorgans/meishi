module ModelMacros

  def create_vcard1
    vcard_raw =
      "BEGIN:VCARD\n" \
      "VERSION:3.0\n" \
      "UID:01\n" \
      "X-AB-UID:01:ABPerson\n" \
      "TEL;TYPE=home,voice:+1-555-555-5555\n" \
      "EMAIL;TYPE=internet,home:scase@aol.com\n" \
      "END:VCARD"
    @vcard1 = Vpim::Vcard.decode(vcard_raw).first
  end

  def create_vcard2
    vcard_raw =
      "BEGIN:VCARD\n" \
      "VERSION:3.0\n" \
      "UID:01\n" \
      "X-AB-UID:01:ABPerson\n" \
      "TEL;TYPE=home,fax:+1-555-555-5555\n" \
      "EMAIL;TYPE=internet,home:scase@aol.com\n" \
      "END:VCARD"
    @vcard2 = Vpim::Vcard.decode(vcard_raw).first
  end

end