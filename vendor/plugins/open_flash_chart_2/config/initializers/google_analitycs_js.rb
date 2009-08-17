if RAILS_ENV.eql?("production") && `hostname`.chomp == 'production'
  GOOGLE_AALITYCS_JS = <<EOF
    <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
      try {
        var pageTracker = _gat._getTracker("UA-6734952-1");
        pageTracker._trackPageview();
      } catch(err) {}
    </script>
EOF
else
  GOOGLE_AALITYCS_JS = ''
end