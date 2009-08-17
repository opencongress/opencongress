class MetaController < ApplicationController
  
	def index
    @page_title = "OpenCongress Meta List"
    @learn_off = true
    @breadcrumb = { 
      1 => { 'text' => "Meta", 'url' => { :controller => 'meta' } }
    }
  end
end
