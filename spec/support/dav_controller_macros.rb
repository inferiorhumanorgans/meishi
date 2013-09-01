module DAVControllerMacros
  class StubWarden
    def initialize(user)
      @user = user
    end
    def authenticate(*args)
      @user
    end
  end

  def request(method, uri, options={})
    options = {
      'HTTP_HOST' => 'localhost',
      'REMOTE_USER' => 'user',
      'warden' => StubWarden.new(User.find(1))
    }.merge(options)
    request = Rack::MockRequest.new(@controller)
    @response = request.request(method, uri, options)
  end

  def response_xml
    @response_xml ||= Nokogiri.XML(response.body)
  end

  def enable_debug_logging
    # Set these so we go over all the debugging code too
    ENV['MEISHI_DEBUG_XML_REQUEST']='2'
    ENV['MEISHI_DEBUG_XML_RESPONSE']='2'
    ENV['MEISHI_DEBUG_REPORT']='2'
    ENV['MEISHI_DEBUG_HTTP_HEADERS']='2'
    ENV['MEISHI_DEBUG_SUPPORTED_PROPS']='2'
  end
end
