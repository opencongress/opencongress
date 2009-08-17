class AboutController < ApplicationController
#  caches_page :index, :blog, :resources, :congress, :howtouse, :rss, :feedback
  skip_before_filter :has_accepted_tos?
  skip_before_filter :store_location, :only => ["privacy_policy","terms_of_service"]

  
  def index
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "About", 'url' => { :controller => 'about' } }
    }
    @page_title = 'About Open Congress'
  end

  def blog
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "About Blog", 'url' => { :controller => 'about', :action => 'blog' } }
    }
    @page_title = 'About OpenCongress Blog'
  end
  
  def resources
    @page_title = "General Overview / Information about Congress"
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "Congress Resources", 'url' => { :controller => 'about', :action => 'resources' } }
    }
  end

  def congress
    # Set @learn_off to remove "Learn More" from the layout
    @learn_off = true
    @page_title = 'About Congress'
  end

  def howtouse
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "How To Use Open Congress", 'url' => { :controller => 'about', :action => 'howtouse'} }
    }
    @page_title = "How To Use Open Congress"
  end
  
  def beta_feedback
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "Feedback", 'url' => { :controller => 'about', :action => 'beta_feedback'} }
    }
    @page_title = "Feedback"
  end
  
  def rss
  	@learn_off = true
  	@breadcrumb = {
  	  1 => { 'text' => "RSS", 'url' => { :controller => 'about', :action => 'rss' } }
  	}
  	@page_title = "Use RSS to Easily Track Developments in Congress"
  end
  
  def political_notebooks
     @learn_off = true
     @page_title = "About My Political Notebook"
  end

  def screencast
    @learn_off
    @page_title = "Screencast"
  end

  def terms_of_service
     @head_title = "Terms of Service and Comment Policy"
  end                                                   
  
  def privacy_policy
     @head_title = "Privacy Policy"
  end

private                            


  def learn_from_controller(controller_name)
    text = render_to_string(:partial => "#{controller_name}/learn")
    process_bluecloth_text(text)
  end
end
