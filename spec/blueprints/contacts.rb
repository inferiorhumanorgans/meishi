Field.blueprint {}

Contact.blueprint do
  created_at      { Time.now }
  updated_at      { Time.now }
  uid             { UUIDTools::UUID.random_create.to_s }
end

Contact.blueprint(:contact1) do
  id              { 1 }
  address_book_id { 1 }
  fields          {
    [

      Field.make!(name: 'FN', value: 'Full Name', contact: object),
      Field.make!(name: 'N',  value: 'Family Name;Given Name;Additional Names;Honorific Prefixes;Honorific Suffixes', contact: object)
    ]
  }
end


=begin
BEGIN:VCARD
VERSION:3.0
N:Gump;Forrest
FN:Forrest Gump
ORG:Bubba Gump Shrimp Co.
TITLE:Shrimp Man
PHOTO;VALUE=URL;TYPE=GIF:http://www.example.com/dir_photos/my_photo.gif
TEL;TYPE=WORK,VOICE:(111) 555-1212
TEL;TYPE=HOME,VOICE:(404) 555-1212
ADR;TYPE=WORK:;;100 Waters Edge;Baytown;LA;30314;United States of America
LABEL;TYPE=WORK:100 Waters Edge\nBaytown, LA 30314\nUnited States of America
ADR;TYPE=HOME:;;42 Plantation St.;Baytown;LA;30314;United States of America
LABEL;TYPE=HOME:42 Plantation St.\nBaytown, LA 30314\nUnited States of America
EMAIL;TYPE=PREF,INTERNET:forrestgump@example.com
REV:2008-04-24T19:52:43Z
END:VCARD
=end
Contact.blueprint(:contact2) do
  id              { 2 }
  address_book_id { 1 }
  fields          {
    [
      Field.make!(contact: object, name: 'N', value: "Gump;Forrest;;;"),
      Field.make!(contact: object, name: 'FN', value: "Forrest Gump"),
      Field.make!(contact: object, name: 'ORG', value: "Bubba Gump Shrimp Co."),
      Field.make!(contact: object, name: 'TITLE', value: "Shrimp Man"),
      Field.make!(contact: object, name: 'PHOTO;VALUE=URL;TYPE=GIF', value: "http://www.example.com/dir_photos/my_photo.gif"),
      Field.make!(contact: object, name: 'TEL;TYPE=WORK,VOICE', value: "(111) 555-1212"),
      Field.make!(contact: object, name: 'TEL;TYPE=HOME,VOICE', value: "(404) 555-1212"),
      Field.make!(contact: object, name: 'ADR;TYPE=WORK', value: ";;100 Waters Edge;Baytown;LA;30314;United States of America"),
      Field.make!(contact: object, name: 'LABEL;TYPE=WORK', value: "100 Waters Edge\\nBaytown, LA 30314\\nUnited States of America"),
      Field.make!(contact: object, name: 'ADR;TYPE=HOME', value: ";;42 Plantation St.;Baytown;LA;30314;United States of America"),
      Field.make!(contact: object, name: 'LABEL;TYPE=HOME', value: "42 Plantation St.\\nBaytown, LA 30314\\nUnited States of America"),
      Field.make!(contact: object, name: 'EMAIL;TYPE=PREF,INTERNET', value: 'forrestgump@example.com'),
      Field.make!(contact: object, name: 'REV', value: "2008-04-24T19:52:43Z"),
    ]
  }
end

=begin
BEGIN:VCARD
VERSION:3.0
N:Doe;John;;;
FN:John Doe
ORG:Example.com Inc.;
TITLE:Imaginary test person
EMAIL;type=INTERNET;type=WORK;type=pref:johnDoe@example.org
TEL;type=WORK;type=pref:+1 617 555 1212
TEL;type=CELL:+1 781 555 1212
TEL;type=HOME:+1 202 555 1212
TEL;type=WORK:+1 (617) 555-1234
item1.ADR;type=WORK:;;2 Example Avenue;Anytown;NY;01111;USA
item1.X-ABADR:us
item2.ADR;type=HOME;type=pref:;;3 Acacia Avenue;Newtown;MA;02222;USA
item2.X-ABADR:us
NOTE:John Doe has a long and varied history\, being documented on more police files that anyone else. Reports of his death are alas numerous.
item3.URL;type=pref:http\://www.example/com/doe
item3.X-ABLabel:_$!<HomePage>!$_
item4.URL:http\://www.example.com/Joe/foaf.df
item4.X-ABLabel:FOAF
item5.X-ABRELATEDNAMES;type=pref:Jane Doe
item5.X-ABLabel:_$!<Friend>!$_
CATEGORIES:Work,Test group
X-ABUID:5AD380FD-B2DE-4261-BA99-DE1D1DB52FBE\:ABPerson
END:VCARD
=end
Contact.blueprint(:contact3) do
  id              { 3 }
  address_book_id { 2 }
  uid             { UUIDTools::UUID.random_create.to_s }
  fields          {
    [
      Field.make!(contact: object, name: 'N',                 value: 'Doe;John;;;'),
      Field.make!(contact: object, name: 'FN',                value: 'John Doe'),
      Field.make!(contact: object, name: 'ORG',               value: 'Example.com Inc.;'),
      Field.make!(contact: object, name: 'TITLE',             value: 'Imaginary test person'),
      Field.make!(contact: object, name: 'EMAIL',             parameters: 'type=INTERNET;type=WORK;type=pref', value: 'johnDoe@example.org'),
      Field.make!(contact: object, name: 'TEL',               parameters: 'type=WORK;type=pref', value: '+1 617 555 1212'),
      Field.make!(contact: object, name: 'TEL',               parameters: 'type=CELL', value: '+1 781 555 1212'),
      Field.make!(contact: object, name: 'TEL',               parameters: 'type=HOME', value: '+1 202 555 1212'),
      Field.make!(contact: object, name: 'TEL',               parameters: 'type=WORK', value: '+1 (617) 555-1234'),
      Field.make!(contact: object, name: 'ADR',               group: 'item1', parameters: 'type=WORK', value: ';;2 Example Avenue;Anytown;NY;01111;USA'),
      Field.make!(contact: object, name: 'X-ABADR',           group: 'item1', value: 'us'),
      Field.make!(contact: object, name: 'ADR',               group: 'item2', parameters: 'type=HOME', value: ';;3 Acacia Avenue;Newtown;MA;02222;USA'),
      Field.make!(contact: object, name: 'X-ABADR',           group: 'item2', value: 'us'),
      Field.make!(contact: object, name: 'NOTE',                              value: 'John Doe has a long and varied history\, being documented on more police files that anyone else. Reports of his death are alas numerous.'),
      Field.make!(contact: object, name: 'URL',               group: 'item3', parameters: 'type=pref', value: 'http\://www.example/com/doe'),
      Field.make!(contact: object, name: 'X-ABLabel',         group: 'item3', value: '_$!<HomePage>!$_'),
      Field.make!(contact: object, name: 'URL',               group: 'item4', value: 'http\://www.example.com/Joe/foaf.df'),
      Field.make!(contact: object, name: 'X-ABLabel',         group: 'item4', value: 'FOAF'),
      Field.make!(contact: object, name: 'X-ABRELATEDNAMES',  group: 'item5', parameters: 'type=pref', value: 'Jane Doe'),
      Field.make!(contact: object, name: 'X-ABLabel',         group: 'item5', value: '_$!<Friend>!$_'),
      Field.make!(contact: object, name: 'CATEGORIES',                        value: 'Work,Test group'),
      Field.make!(contact: object, name: 'X_ABUID',                           value: '5AD380FD-B2DE-4261-BA99-DE1D1DB52FBE\:ABPerson')
    ]
  }
end

