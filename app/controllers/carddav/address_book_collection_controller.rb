class Carddav::AddressBookCollectionController < Carddav::BaseController

  def initialize(request, response, options={})
    super

    @verbs -= %w(HEAD GET PUT POST DELETE MKCOL COPY MOVE)

    self
  end

  def get
    @response['Allow'] = verbs
    MethodNotAllowed
  end

end
