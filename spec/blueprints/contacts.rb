Contact.blueprint(:contact1) do
  address_book_id { 1 }
  uid             { UUIDTools::UUID.random_create.to_s }
  fields          {
    [Field.make!(:field1, :contact => object), Field.make!(:field2, :contact => object)]
  }
end

Field.blueprint(:field1) do
  name  {"FN"}
  value {"Full Name"}
end

Field.blueprint(:field2) do
  name {"N"}
  value {"Family Name;Given Name;Additional Names;Honorific Prefixes;Honorific Suffixes"}
end