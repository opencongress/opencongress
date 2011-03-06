module RemoteForgeryProtection
  JS_FILE_NAME = "remote_forgery_protection.js"
  JS_FILE_PATH = "public/javascripts/#{JS_FILE_NAME}"
    
  class << self
    
    def javascript_code
      %{
// Let's add authenticity token to all Ajax requests. 
// Prototype
if (typeof(Prototype) != "undefined") {
  Ajax.Base.prototype.initialize = Ajax.Base.prototype.initialize.wrap(function() {
    var args = $A(arguments), proceed = args.shift();
    args[0] = args[0] || {};
    var options = args[0];
    if (!(options.method && options.method.toUpperCase() == "GET")) {
      var encodedToken = encodeURIComponent(_token);
      if (Object.isString(options.parameters)) {
        if (options.parameters.indexOf("authenticity_token") == -1)
          options.parameters += '&authenticity_token=' + encodedToken;
      } else if (Object.isHash(options.parameters)) {
        options.parameters = options.parameters.toObject();
        options.parameters.authenticity_token = encodedToken;
      } else {
        options.parameters = options.parameters || {};
        options.parameters.authenticity_token = encodedToken;
      }
    }
    proceed.apply(null, args);
  });
}
// ExtJS
if (typeof(Ext) != "undefined") {
  Ext.Ajax.on('beforerequest', function(conn, options) {
    if (!(options.method && options.method.toUpperCase()=="GET")) {
      if (Ext.isString(options.params)) {
        if (options.params.indexOf("authenticity_token") == -1)
          options.params = String.format('{0}&authenticity_token={1}', options.params, _token);
      } else {
        options.params = options.params || {};
        options.params.authenticity_token = _token;
      }
    }
  });
}
// jQuery
if (typeof(jQuery) != "undefined") {
  (function(jQuery){
    var originalAjax = jQuery.ajax;
    jQuery.extend({
      ajax: function(o) {
        if (!(o.type && o.type.toUpperCase()=="GET")) {
          o.data = o.data || {};
          if (typeof(o.data)==="string") {
            if (o.data.indexOf("authenticity_token") == -1)
              o.data += "&authenticity_token="+_token;
          } else {
            o.data.authenticity_token = _token;
          }
        }
        return originalAjax.call(this, o);
      }
    });
  })(jQuery);
}
      }
    end
    
  end
  
end
