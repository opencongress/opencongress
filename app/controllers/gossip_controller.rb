class GossipController < ApplicationController
  verify :method => :post, :only => %w(update tip)
  before_filter :login_required, :only => [:admin]
  before_filter :can_gossip, :only => [:admin]

  def index
    @page_title = "Congress Gossip"
    @gossip = Gossip.latest(10)
    @atom = {'link' => url_for(:only_path => false, :controller => 'gossip', :action => 'atom'), 'title' => "Gossip from the OC"}

  end

  def submit
    @page_title = "Send us a tip about Congress"
  end
  
  def hot
    redirect_to :controller => 'bill', :action => 'hot'
  end


  def tip
    name = params['tip']['name']
    email = params['tip']['email']
    link = params['tip']['link']
    tip = params['tip']['tip']
    g = Gossip.create :name => name, :email => email, :link => link, :tip => tip
    if g.new_record?
      blank_fields = ['name','email','tip'].select { |f| params['tip'][f].blank? }
      flash[:notice] = "Blank " + blank_fields.to_sentence
      redirect_to :action => 'submit'
    else
      flash[:notice] = "Thanks for submitting a tip!"
      redirect_to :action => 'index'
    end
  end

  def admin
    @page_title = "Update Gossip"
    @gossip = Gossip.for_admin
  end

  def update
    g = Gossip.find params["id"]

    if params['commit'] == "delete"
      g.destroy
      redirect_to :action => 'admin'
      return
    end

    case params['commit']
    when "unapprove"
      g.approved = false
    when "approve"
      g.approved = true
    when "gossip page" 
      g.frontpage = false
    when "front page"
      g.frontpage = true
    end

    g.title = params['tip']['title']
    g.tip = params['tip']['tip'] 
    g.save
    redirect_to :action => 'admin'
  end
  
  def atom
    @gossip = Gossip.latest
     expires_in 60.minutes, :public => true
   
    render :layout => false
  end
  private
  def can_gossip
    if !(user_signed_in? && current_user.user_role.can_manage_text)
      redirect_to :controller => 'gossip', :action => 'index'
    end
  end
end
