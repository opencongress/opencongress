class VideoController < ApplicationController
  before_filter :set_video_styles
  
  def index
    redirect_to :action => 'all'
  end
  
  def all
    @videos = Video.paginate(:all, :order => 'video_date DESC', :page => params[:page])
    @page_title = "All Videos"
    @atom = {'link' => url_for(:only_path => false, :controller => 'video', :action => 'rss'), 'title' => "All Videos RSS"}
    
    respond_to do |format|
      format.html # all.html.erb
      format.atom # all.atom.builder
    end
  end
  
  protected
  def set_video_styles
    @include_vids_styles = true
  end
end
