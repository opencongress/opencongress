# Carl Tashian's S3 hack for delivering compressed asset URLs ending with .js.gz
# when possible, instead of using content negotiation (because S3 doesn't have that).
unless ActionController::Base.asset_host.blank?
  klass = Jammit::Helper

  klass.module_eval do
    # This depends on gzipped S3 assets sending the proper Content-Type and Content-Encoding strings
    # so that browsers will know to decompress them. Setting those is a function of the OpenCongress 
    # version of the symch_s3_asset_host plugin.

    # Note that for proper caching, our web server should send Vary: Accept-Encoding
    # or Vary: User-Agent (or both) so we don't send the wrong things to the wrong browsers.

    # Writes out the URL to the bundled and compressed javascript package,
    # except in development, where it references the individual scripts.
    def include_javascripts(*packages)
      tags = packages.map do |pack|
        Jammit.package_assets ? Jammit.asset_url(pack, (defined?(request.env['HTTP_ACCEPT_ENCODING']) && request.env['HTTP_ACCEPT_ENCODING'].scan('gzip').length > 0 ? :jsgz : :js)) : Jammit.packager.individual_urls(pack.to_sym, :js)
      end
      javascript_include_tag(tags.flatten)
    end

    private
  
    # HTML tags for the stylesheet packages.
    def packaged_stylesheets(packages, options)
      tags_with_options(packages, options) {|p| Jammit.asset_url(p, (defined?(request.env['HTTP_ACCEPT_ENCODING']) && request.env['HTTP_ACCEPT_ENCODING'].scan('gzip').length > 0 ? :cssgz : :css)) }
    end

  end
end
