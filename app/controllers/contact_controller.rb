class ContactController < ApplicationController
  #before_filter :login_required, :except => :index
  
  def bill
    @page_title = "Contact Congress"
    @bill = Bill.find_by_ident(params[:id])
  

    if logged_in?
      @sens = current_user.my_sens
      @reps = current_user.my_reps
  
      if @sens.empty? && @reps.empty?
        flash[:notice] = "In order to contact your representatives in Congress, you must configure your account.  Please enter your zipcode and address in the form below."
        redirect_to user_profile
      end
    else
      @sens = @reps = []
    end
  
    if params[:position].nil?
      render 'select_position'
      return
    end
      
    formageddon_configured = false
    ### loop through recipients and see if formageddon is configured
    
    
    @position = params[:position]
  
    case @position
    when 'support'
      message_start = "I support #{@bill.typenumber} - #{@bill.title_common}, and am tracking it using OpenCongress.org, the free public resource website for government transparency and accountability."      
    when 'oppose'
      message_start = "I oppose #{@bill.typenumber} - #{@bill.title_common}, and am tracking it using OpenCongress.org, the free public resource website for government transparency and accountability."      
    else
      message_start = "I'm tracking #{@bill.typenumber} - #{@bill.title_common} using OpenCongress.org, the free public resource website for government transparency and accountability."
    end
  
    @formageddon_thread = Formageddon::FormageddonThread.new
    @formageddon_thread.prepare(:user => current_user, :subject => @bill.typenumber, :message => message_start)
    @formageddon_thread.formageddon_recipient = @sens.first
  end
  
  def person
  end
  
  def get_recipients
    @sens, @reps = Person.find_current_congresspeople_by_zipcode(params[:zip], nil)
    
    @reps = [] unless @reps.size == 1
    
    render :partial => 'contact/contact_recipients'
  end
  
  def showthread
    @thread = Formageddon::FormageddonThread.find(params[:id])
    
    @page_title = "Letter to #{@thread.formageddon_recipient.name}"
  end
  
  def aftersend
    @thread = Formageddon::FormageddonThread.find(params[:thread_id])
  end
end
