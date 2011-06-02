CarrierWave.configure do |config|
  config.s3_access_key_id = ApiKeys.aws_access_key_id
  config.s3_secret_access_key =  ApiKeys.aws_secret_access_key
  config.s3_bucket = "a0.opencongress.org"
  # Note: S3 uploads into "uploads" dir on the host.
end
