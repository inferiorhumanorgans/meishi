# Meishi

__A lightweight CardDAV server built on Rails 3__

Yup.  Lightweight, and not in the LDAP is lightweight sense.  Meishi aims to be lightweight and easy to deploy in the "install a few gems and go" sense.

## Requirements

* Rails 3.2
* Devise
* Dav4Rack from the inferiorhumanorgans respository
* Unicorn (optional)

### Testing Requirements
* Rspec-rails
* Machinist

## Getting Started (server)

To get started:

* Unpack the application (git clone, tar xf, unzip, etc)
* Do the bundle stuff
* Edit the database configuration file at config/database.yml as needed
* Use rake to run the migrations (db:migrate)
* Run the meishi:first_run task, and follow the prompts
* Deploy with your favorite rack server (phusion, unicorn, mongrel, etc)

## Getting Started (client)

### Android CardDAV-Sync

Read only support has been tested.  Autodiscovery should work, takes a principal URL will present the user with a list of address books to choose from.  Ex: https://carddav.example.com/carddav/

### BlackBerry OS 10

CardDAV support in versions prior to 10.2 is broken beyond repair.  10.2 has been tested and should work OK.  However, BlackBerryOS will only attempt a CardDAV connection over HTTPS.  This means Meishi needs to be put behind a proxy (such as Apache or nginx) or run with webrick configured to handle SSL connections.  BlackBerryOS will not parse principal URLs for CardDAV accounts, instead it will only let a user input a host name/address, port, and path of the principal URL.

### CardDavMate

CardDavMate needs a few modifications in order to work.  First, as it's
browser based, config.permissive_cross_domain_policy needs to be set to
**true** in config/initializers/meishi.rb if meishi is running on a different
host than CardDavMate.  Then, the hardcoded-for-davical regexp in config.js
needs to be removed.  And, finally, webdav_protocol.js needs to be edited to
set the Depth header properly on an addressbook-multiget report (currently
line 2177).

### MacOS X

AddresBook.app has been tested with 10.6.8 and a single address book, and
autodiscovery should work.  Takes the principal URL *with the port number*.
Ex: http://carddav.example.com:80/carddav/  Contacts.app in OSX 10.8 has
been tested and should work.

### pyCardDAV

As of d9f4440, pyCardDAV should work.  It takes an address book URL.  Ex:
http://carddav.example.com/book/123/

### SoGo Connector

Has been tested with Thunderbird 11 and read/write support should work.  Takes
an address book URL.  The address book ID can be found from the web interface.
Ex:  http://carddav.example.com:80/book/123/

## Standards Compliance

Meishi aims to be fully standards compliant CardDAV contacts server.  That means calendaring support (ex: CalDAV) is not likely to be implemented.  The immediate goal is simply to provide enough CardDAV compliance to function with most clients.  I'm currently working on a compliance suite (see the [carddav_test_suite](https://github.com/inferiorhumanorgans/carddav_test_suite) project).

### Current status of compliance

Because calendaring is not a goal, RFCs [4324](http://tools.ietf.org/html/rfc4324), [4791](http://tools.ietf.org/html/rfc4791) and [5546](http://tools.ietf.org/html/rfc5546) aren't (and won't be) on my radar.  [Wikipedia](http://en.wikipedia.org/wiki/Comparison_of_CalDAV_and_CardDAV_implementations) breaks down the server compliance into the following categories:

* HTTP/1.1 ([RFC 2616](http://tools.ietf.org/html/rfc2616))
  - Because Meishi is using Rack+Rails+dav4rack the assumption is that it is HTTP/1.1 compliant.
* HTTP Authentication ([RFC 2617](http://tools.ietf.org/html/rfc2617))
  - Meishi supports 'basic' HTTP authentication.  Because Meishi does not store passwords in plaintext, 'digest'
  authentication has not been enabled.  As digest authentication with password hashes presents similar problems to storing 
  plaintext passwords, digest authentication will not be supported.  Additionally support for any other authentication 
  schemes requiring storage of plaintext passwords is not currently planned.  Authentication method negotiation is not 
  currently implemented.  As rack is designed to be used behind an external HTTP server, the expectation is that users will 
  configure their HTTP server to handle TLS connections and thus make basic authentication 
  reasonably secure.
* WebDAV ([RFC 2518](http://tools.ietf.org/html/rfc2518))
  - As Meishi uses dav4rack, it is mostly WebDAV compliant.  As of [39cfc0088a](https://github.com/inferiorhumanorgans/dav4rack/commit/39cfc0088a), [dav4rack](https://github.com/inferiorhumanorgans/dav4rack) will pass all but two of the tests
  in the [WebDAV Litmus suite](http://www.webdav.org/neon/litmus/).  Better handling for namespace edge cases is needed in both Meishi and dav4rack.
* WebDAV Versioning Extensions ([RFC 3253](http://tools.ietf.org/html/rfc3253))
  - There is partial support.  There's no intent of having Meishi present versioned contacts, but as CardDAV requires
  support for the DAV:supported-report-set property, that's been implemented.
* WebDAV Access Control ([RFC 3744](http://tools.ietf.org/html/rfc3744))
  - Much of [RFC 3744](http://tools.ietf.org/html/rfc3744) is implemented, work needs to be done to ensure that generic ACL properties are available on 
  non-principal resources.
* Apple Calendar Access Protocol ([RFC 4324](http://tools.ietf.org/html/rfc4324))
  - No, n/a.
* WebDAV Mounting ([RFC 4709](http://tools.ietf.org/html/rfc4709))
  - I haven't evaluated how I'd want to integrate this support.  As most CardDAV clients are likely to make the assumption
  of the server speaking WebDAV, I don't see this as a high priority (or very useful).
* CalDAV ([RFC 4791](http://tools.ietf.org/html/rfc4791))
  - No, n/a.
* WebDAV, 2007 revision ([RFC 4918](http://tools.ietf.org/html/rfc4918))
  - Unsure as I've not looked at the differences between this and [RFC 2518](http://tools.ietf.org/html/rfc5546)
* WebDAV Current Principal ([RFC 5397](http://tools.ietf.org/html/rfc5397))
  - Yes.
* iCal/iTIP ([RFC 5546](http://tools.ietf.org/html/rfc5546))
  - No, n/a.
* WebDAV extended MKCOL ([RFC 5689](http://tools.ietf.org/html/rfc5689))
  - Not yet implemented.  Currently users and address books are provisioned with the web based interface.
* CardDAV ([RFC 6352](http://tools.ietf.org/html/rfc6352))
  - Some.  Working on it.

## TODO

* Submit pull requests to or properly fork dav4rack so we can use it as a gem and not from a git repo
* Tests, tests, and more tests
* Fill in the DAV bits
* grep -r TODO * | egrep -v "^(README|Binary)" | cut -d ' ' -f 2- | sed 's/.*#.//g'

## License

4-clause BSD unless otherwise noted.
