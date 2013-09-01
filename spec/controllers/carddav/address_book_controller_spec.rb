require 'spec_helper'

describe Carddav::AddressBookController do

  include DAVControllerMacros

  always_login_user_1

  before(:each) do
    @controller = DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookResource,
      :controller_class => Carddav::AddressBookController
    )

    AddressBook.make!(:address_book1)
    AddressBook.make!(:address_book2)
    Contact.make!(:contact1)
    Contact.make!(:contact2)

    enable_debug_logging
  end

  METHODS = %w(GET PUT POST DELETE PROPFIND PROPPATCH MKCOL COPY MOVE OPTIONS HEAD LOCK UNLOCK REPORT)
  METHODS.each do |method|
    define_method(method.downcase) do |*args|
      request(method, *args)
    end
  end

  describe "GET /book/1" do
    it "should return a method-not-allowed failure" do
      get('/book/1')
      response.status.should eq DAV4Rack::HTTPStatus::MethodNotAllowed.code
    end
  end

  describe "OPTIONS /book/1" do
    it "should do its thing" do
      options('/book/1')
      response.should be_ok
      response.headers.should include 'Allow'
    end
  end

  describe "PROPFIND addressbook 1" do
    it "should treat an empty request as an allprop request" do
      propfind('/book/1')
      response.body.length.should be > 0
    end
  end

  describe "REPORT" do
    it "should return 404-not-found for an unknown address book" do
      report('/book/1024')
      response.status.should eq DAV4Rack::HTTPStatus::NotFound.code
    end

    it "should return 400-bad-request for an empty request body" do
      report('/book/1')
      response.status.should eq DAV4Rack::HTTPStatus::BadRequest.code
    end

    it "should return the proper error data for an unsupported report" do
      # RFC 3253 §1.6: Precondition not met: 403 - never try again, 409 - fix and try later
      report('/book/1', input: '<newfangled-report></newfangled-report>')
      response.status.should eq DAV4Rack::HTTPStatus::Forbidden.code
      response_xml.xpath('/D:error/D:supported-report', response_xml.root.namespaces).should_not be_empty
    end
  end

  describe "addressbook-query" do
    it "should work" do
      s='
      <C:addressbook-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:carddav">
        <D:prop>
          <D:getetag/>
          <C:address-data content-type="text/vcard" version="3.0">
            <C:prop name="VERSION"/>
            <C:prop name="UID"/>
            <C:prop name="NICKNAME"/>
            <C:prop name="EMAIL"/>
            <C:prop name="FN"/>
            <C:prop name="TEL"/>
          </C:address-data>
        </D:prop>
        <C:filter test="anyof">
          <C:prop-filter name="FN" test="allof">
            <C:text-match collation="i;unicode-casemap" match-type="contains">Gump</C:text-match>
          </C:prop-filter>
          <C:prop-filter name="FN" test="anyof">
            <C:text-match collation="i;unicode-casemap" match-type="contains">cond3</C:text-match>
            <C:text-match collation="i;unicode-casemap" match-type="contains">cond4</C:text-match>
          </C:prop-filter>
        </C:filter>
      </C:addressbook-query>
      '

      report('/book/1', input: s)
      response.status.should eq DAV4Rack::HTTPStatus::MultiStatus.code
      response_xml.xpath('/D:error', response_xml.root.namespaces).should be_empty
      
    end
  end

  describe "addressbook-multiget" do
    ['infinity', '1', nil].each do |depth|
      it "should respond with 400-bad-request when the depth header == #{depth.inspect}" do
        s='
        <C:addressbook-multiget xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:carddav">
          <D:prop>
            <D:getetag/>
            <C:address-data content-type="text/vcard" version="3.0">
              <C:prop name="VERSION"/>
              <C:prop name="UID"/>
              <C:prop name="NICKNAME"/>
              <C:prop name="EMAIL"/>
              <C:prop name="FN"/>
              <C:prop name="TEL"/>
            </C:address-data>
          </D:prop>
          <D:href>/book/1/foo</D:href>
        </C:addressbook-multiget>
        '

        report('/book/1', input: s, 'HTTP_DEPTH' => depth)
        response.status.should eq DAV4Rack::HTTPStatus::BadRequest.code
        response_xml.xpath('/D:error/D:invalid-depth', response_xml.root.namespaces).should_not be_empty
      end
    end

    it "should respond with 400-bad-request when no hrefs are given" do
      s='
      <C:addressbook-multiget xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:carddav">
        <D:prop>
          <D:getetag/>
          <C:address-data content-type="text/vcard" version="3.0">
            <C:prop name="VERSION"/>
            <C:prop name="UID"/>
            <C:prop name="NICKNAME"/>
            <C:prop name="EMAIL"/>
            <C:prop name="FN"/>
            <C:prop name="TEL"/>
          </C:address-data>
        </D:prop>
      </C:addressbook-multiget>
      '

      report('/book/1', input: s, 'HTTP_DEPTH' => '0')
      response.status.should eq DAV4Rack::HTTPStatus::BadRequest.code
      response_xml.xpath('/D:error/D:href-missing', response_xml.root.namespaces).should_not be_empty
    end

    it "should work" do
      s="
      <C:addressbook-multiget xmlns:D='DAV:' xmlns:C='urn:ietf:params:xml:ns:carddav'>
        <D:prop>
          <D:getetag/>
          <C:address-data content-type='text/vcard' version='3.0'>
            <C:prop name='VERSION'/>
            <C:prop name='UID'/>
            <C:prop name='NICKNAME'/>
            <C:prop name='EMAIL'/>
            <C:prop name='FN'/>
            <C:prop name='TEL'/>
          </C:address-data>
        </D:prop>
        <D:href>/book/1/foo</D:href>
        <D:href>/book/1/#{AddressBook.find(1).contacts.first.uid}</D:href>
      </C:addressbook-multiget>
      "

      report('/book/1', input: s, 'HTTP_DEPTH' => '0')
      response.status.should eq DAV4Rack::HTTPStatus::MultiStatus.code
      response_xml.xpath('/D:error', response_xml.root.namespaces).should be_empty
    end
  end
end
