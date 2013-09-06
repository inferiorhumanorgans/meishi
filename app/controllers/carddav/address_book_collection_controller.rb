class Carddav::AddressBookCollectionController < Carddav::BaseController

  def initialize(request, response, options={})
    super

    @verbs = 'OPTIONS,PROPFIND,PROPPATCH,REPORT,LOCK,UNLOCK'

    self
  end

  def get
    @response['Allow'] = @verbs
    MethodNotAllowed
  end

end
