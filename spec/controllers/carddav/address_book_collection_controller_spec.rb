require 'spec_helper'

describe Carddav::BaseController do

  include DAVControllerMacros

  always_login_user_1

  before(:each) do
    @controller = DAV4Rack::Handler.new(
      :root => '/book',
      :root_uri_path => '/book',
      :resource_class => Carddav::AddressBookCollectionResource,
      :controller_class => Carddav::BaseController
    )

    AddressBook.make!(:address_book1)
    AddressBook.make!(:address_book2)
    Contact.make!(:contact1)
    Contact.make!(:contact2)

    enable_debug_logging
  end

  describe "GET /book/" do
    it "should return a method-not-allowed failure" do
      get('/book/')
      response.status.should eq DAV4Rack::HTTPStatus::MethodNotAllowed.code
    end
  end

  describe "OPTIONS /book/" do
    it "should do its thing" do
      options('/book/')
      response.should be_ok
      response.headers.should include 'Allow'
    end
  end

  describe "PROPFIND books" do
    RSpec::Matchers.define :contain_property do |prop, ns_url|
      match do |xml|
        # So gross: https://github.com/sparklemotion/nokogiri/issues/656
        base_xpath = '/D:multistatus/D:response/D:href[contains(.,"/book/") and string-length(.) = "6"]/following-sibling::D:propstat/D:status[starts-with(.,"HTTP/1.") and contains(.," 200 ")]/preceding-sibling::D:prop'
        base_ns = {'D' => 'DAV:'}
        xml.xpath("count(#{base_xpath}/X:#{prop})", base_ns.merge('X' => ns_url)) == 1.0
      end

      failure_message_for_should do |actual|
        "expected that there would be one #{ns_url}#{prop}"
      end

      failure_message_for_should_not do |actual|
        "expected that there would not be one #{ns_url}#{prop}"
      end

      description do
        "be a precise multiple of #{expected}"
      end
    end

    it "should treat an empty request as an allprop request" do
      propfind('/book/', 'HTTP_DEPTH' => '0')

      allprops = {
        'DAV:' => %w(creationdate current-user-principal displayname getlastmodified principal-URL resourcetype),
      }

      allprops.each do |ns_url, props|
        props.each do |curprop|
          response_xml.should contain_property(curprop, ns_url)
        end
      end

      response.body.length.should be > 0
    end
  end

  explicit_props = {
    'DAV:' => %w(
      acl
      acl-restrictions
      current-user-privilege-set
      group
      inherited-acl-set
      owner
      principal-collection-set
      supported-privilege-set
    )
  }
  explicit_props.each do |namespace_url, properties|
    properties.each do |prop|
      it "should have the property #{namespace_url}#{prop} " do
        s="
        <?xml version='1.0' encoding='utf-8' ?>
        <D:propfind xmlns:D='DAV:' xmlns:X='#{namespace_url}'>
          <D:prop>
            <X:#{prop}/>
          </D:prop>
        </D:propfind>
        "
        propfind('/book/', input: s, 'HTTP_DEPTH' => '0')
        response.status.should eq DAV4Rack::HTTPStatus::MultiStatus.code
        response_xml.xpath('/D:error', response_xml.root.namespaces).should be_empty
        response_xml.should contain_property(prop, namespace_url)
      end
    end
  end

end
