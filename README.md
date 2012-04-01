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

* Unpack the application (git clone, tar -xf, unzip, etc)
* Do the bundle stuff
* Edit the database configuration file at config/database.yml as needed
* Use rake to run the migrations (db:migrate)
* Run the rake task meishi:first_run and follow the prompts
* Deploy with your favorite rack server (phusion, unicorn, mongrel, etc)

## Getting Started (client)

### Android CardDAV-Sync

Read only support has been tested.  Autodiscovery should work, takes a principal URL will present the user with a list of address books to choose from.  Ex: https://carddav.example.com:80/carddav/

### CardDavMate

Read only support has been tested.  Should work once you rip out the hardcoded-for-davical regexp in config.js.

### MacOS X AddresBook.app

Has been tested with 10.6.8 and a single address book, and autodiscovery should work.  Takes the principal URL with the port number. Ex: https://carddav.example.com:80/carddav/

### SoGo Connector

Has been tested with Thunderbird 11 and read/write support should work.  Takes an address book URL.  The address book ID can be found from the web interface.  Ex:  https://carddav.example.com:80/book/123/

## TODO

* Submit pull requests to or properly fork dav4rack so we can use it as a gem and not a deprecated plugin
* Tests, tests, and more tests
* Fill in the DAV bits
* Refactor the DAV controller
* grep -r TODO * | egrep -v "^(README|Binary)" | cut -d ' ' -f 2- | sed 's/.*#.//g'

## License

4-clause BSD unless otherwise noted.