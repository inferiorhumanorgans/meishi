namespace :meishi do
  desc "Run this from Travis"
  task :setup_test => :environment do
    # Change this to change how many characters are in our salt
    SALT_SIZE=128

    # 40 through 126 allows us to easily exclude ASCII characteres that
    # would need to be escaped in a single quoted string, change as desired.
    SALT_CHAR_RANGE=40..126

    STDOUT.puts "Generating session secret"
    sess_secret = ''
    SALT_SIZE.times do
      sess_secret << rand(SALT_CHAR_RANGE).chr
    end

    STDOUT.puts "Generating user password salt"
    pass_secret = ''
    SALT_SIZE.times do
      pass_secret << rand(SALT_CHAR_RANGE).chr
    end

    STDOUT.puts "Saving salts"
    File.open('config/initializers/00_first_initializer.rb', 'w+') do |f|
      f.puts "Meishi::Application.config.secret_token = '#{sess_secret}'"
      f.puts "Meishi::Application.config.devise_user_salt = '#{pass_secret}'"
    end

  end
end

