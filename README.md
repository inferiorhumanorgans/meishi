# Meishi

__A lightweight CardDAV server built on Rails 3__

## Requirements

* Rails 3.2
* Devise
* Dav4Rack from the inferiorhumanorgans respository
* Unicorn (optional)

### Testing Requirements
* Rspec-rails
* Machinist

## Getting Started

To get started:

* Unpack the application (git clone, tar -xf, unzip, etc)
* Do the bundle stuff
* Edit the database configuration file at config/database.yml as needed
* Run the migrations (rake db:migrate)
* Run rake meishi:first_run and follow the prompts
* Deploy with your favorite rack server (phusion, unicorn, mongrel, etc)

## TODO

* Submit pull requests to or properly fork dav4rack so we can use it as a gem and not a deprecated plugin
* Tests, tests, and more tests
* Fill in the DAV bits
* Refactor the DAV controller
* grep -r TODO * | egrep -v "^(README|Binary)" | cut -d ' ' -f 2- | sed 's/.*#.//g'

## License

GPLv3 unless otherwise noted.