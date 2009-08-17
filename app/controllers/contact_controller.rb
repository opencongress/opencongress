class ContactController < ApplicationController
  caches_page :index
  
  def index
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "Contact Us", 'url' => { :controller => 'contact' } }
    }
  end
end
