class CacheController < ApplicationController
  before_filter :check_local_request
  
  def expire_cache_fragment
    expire_fragment(params[:id])
    
    render :nothing => true
  end
  
  private
  def check_local_request
    unless local_request?
      redirect_to :controller => 'index'
    end
  end
end