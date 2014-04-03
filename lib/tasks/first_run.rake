namespace :meishi do
  desc "Run this first"
  task :first_run => :environment do

    # Change this to change how many characters are in our salt
    SALT_SIZE=128

    # 40 through 126 allows us to easily exclude ASCII characteres that
    # would need to be escaped in a single quoted string, change as desired.
    # Skip ASCII code 47 (backslash char), to avoid possible escaping of last single quote in generated string
    SALT_CHAR_ARRAY=(40..126).to_a - [47]

    STDOUT.puts "Generating session secret"
    sess_secret = ''
    SALT_SIZE.times do
      sess_secret << SALT_CHAR_ARRAY.sample.chr
    end

    STDOUT.puts "Generating user password salt"
    pass_secret = ''
    SALT_SIZE.times do
      pass_secret << SALT_CHAR_ARRAY.sample.chr
    end

    STDOUT.puts "Saving salts"
    File.open('config/initializers/00_first_initializer.rb', 'w+') do |f|
      f.puts "Meishi::Application.config.secret_token = '#{sess_secret}'"
      f.puts "Meishi::Application.config.devise_user_salt = '#{pass_secret}'"
    end

    # Explicitly set the password salt so we can generate usable passwords
    Devise.setup do |config|
      config.pepper = pass_secret
    end

    STDOUT.puts

    STDOUT.puts "Now we need to set up our administrative user"
    user = {}
    %w(username email password).each do |attrib|
      STDOUT.printf "\t%s: " % attrib.titleize
      STDOUT.flush

      # If we're asking for a password like attribute, don't echo it to the terminal
      system 'stty -echo' if attrib =~ /password/

      user[attrib.to_sym] = STDIN.gets.chomp

      if attrib =~ /password/
        system 'stty echo'
        STDOUT.puts
      end
    end
    u = User.new(user)
    u.admin = true
    u.save!
  end
end