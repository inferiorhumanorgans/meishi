User.blueprint(:user1) do
  username { 'blah' }
  email    { 'bla@blablah.com' }
  password { 'blax123' }
end

User.blueprint(:user2) do
  username { "halb" }
  email    { "bla@blabla.com" }
  password { "blax123" }
end