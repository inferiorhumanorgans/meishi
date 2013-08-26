Meishi::Application.configure do

  config.meishi_version = '0.2'
  config.meishi_long_version = 'Meishi v0.2'

  # :absolute, :percent, :off
  config.quota_global_limit = :percent

  # Per above.  Bytes, percentage of disk size, or ignored
  # Default is 15% of the disk space.
  config.quota_global_value = 15

  config.quota_max_vcard_size = 1.kilobyte

  # Set to true for remote access from a browser (ex: CardDAVMate)
  config.permissive_cross_domain_policy = false

  config.max_number_of_results_per_report = 20
end
