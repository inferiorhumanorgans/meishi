Meishi::Application.configure do

  # :absolute, :percent, :off
  config.quota_global_limit = :percent

  # Per above.  Bytes, percentage of disk size, or ignored
  # Default is 15% of the disk space.
  config.quota_global_value = 15

  config.quota_max_vcard_size = 1.kilobyte
end
