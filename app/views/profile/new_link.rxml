xml.instruct!

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do

  xml.title   "OpenCongress" 
  xml.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'profile', :action => :profile, :login => params[:login] )
  xml.updated Time.new.strftime("%Y-%m-%dT%H:%M:%SZ")
  xml.author  { xml.name "opencongress.org" }

  xml.entry do

    xml.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'profile', :action => :profile, :login => params[:login] )
    xml.updated Time.new.strftime("%Y-%m-%dT%H:%M:%SZ")
    xml.title   "Feed URL's have Changed"
    xml.content "type" => "html" do
      xml.text! "As a result of enhancements to the OpenCongress, and the introduction of privacy settings, feed URLs for My OpenCongress have changed.  Please " + link_to("Login", {:controller => :account, :action => :login})+ " and visit your " + link_to("Profile", {:controller => :profile, :action => :profile, :login => @user.login}) + " to adjust your privacy settings, as well as retrieve the new links for your feeds.  We apologize for the inconvenience."
    end
  end
end
