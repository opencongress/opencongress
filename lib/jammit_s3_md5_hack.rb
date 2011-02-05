require 'mimemagic'
require 'digest/md5'

module Jammit
  class S3Uploader
    def initialize(options = {})
      @bucket = options[:bucket]
      unless @bucket
        @bucket_name = options[:bucket_name] || Jammit.configuration[:s3_bucket]
        @access_key_id = options[:access_key_id] || Jammit.configuration[:s3_access_key_id]
        @secret_access_key = options[:secret_access_key] || Jammit.configuration[:s3_secret_access_key]
        @bucket_location = options[:bucket_location] || Jammit.configuration[:s3_bucket_location]
        @cache_control = options[:cache_control] || Jammit.configuration[:s3_cache_control]
        @acl = options[:acl] || Jammit.configuration[:s3_permission]

        @bucket = find_or_create_bucket
      end
    end

    def upload
      log "PUSHING assets to S3 bucket: #{@bucket.name}"
      globs = []

      # add default package path
      if Jammit.gzip_assets
        globs << "public/#{Jammit.package_path}/**/*.gz"
      else
        globs << "public/#{Jammit.package_path}/**/*.css"
        globs << "public/#{Jammit.package_path}/**/*.js"
      end

      # add images
      globs << "public/images/**/*"

      # add custom configuration if defined
      s3_upload_files = Jammit.configuration[:s3_upload_files]
      globs << s3_upload_files if s3_upload_files.is_a?(String)
      globs += s3_upload_files if s3_upload_files.is_a?(Array)

      # upload all the globs
      globs.each do |glob|
        upload_from_glob(glob)
      end
    end

    def upload_from_glob(glob)
      log "Pushing files from #{glob}"
      log "#{ASSET_ROOT}/#{glob}"
      Dir["#{ASSET_ROOT}/#{glob}"].each do |local_path|
        next if File.directory?(local_path)
        remote_path = local_path.gsub(/^#{ASSET_ROOT}\/public\//, "")

        use_gzip = false

        # handle gzipped files
        if File.extname(remote_path) == ".gz"
          use_gzip = true
          remote_path = remote_path.gsub(/\.gz$/, "")
        end
        
        # check if the file already exists on s3
        begin
          obj = @bucket.objects.find_first(remote_path)
        rescue
          obj = nil
        end

        # if the object does not exist, or if the MD5 Hash / etag of the 
        # file has changed, upload it
        if !obj || (obj.etag != Digest::MD5.hexdigest(File.read(local_path)))
          log "pushing file to s3: #{remote_path}"

          # save to s3
          new_object = @bucket.objects.build(remote_path)
          new_object.cache_control = @cache_control if @cache_control
          new_object.content_type = MimeMagic.by_path(remote_path)
          new_object.content = open(local_path)
          new_object.content_encoding = "gzip" if use_gzip
          new_object.acl = @acl if @acl
          new_object.save
        else
          log "file has not changed: #{remote_path}"
        end     
      end
    end

    def find_or_create_bucket
      s3_service = S3::Service.new(:access_key_id => @access_key_id, :secret_access_key => @secret_access_key)

      # find or create the bucket
      begin
        s3_service.buckets.find(@bucket_name)
      rescue S3::Error::NoSuchBucket
        log "Bucket not found. Creating '#{@bucket_name}'..."
        bucket = s3_service.buckets.build(@bucket_name)

        location = (@bucket_location.to_s.strip.downcase == "eu") ? :eu : :us
        bucket.save(location)
        bucket
      end
    end

    def log(msg)
      puts msg
    end

  end

end
