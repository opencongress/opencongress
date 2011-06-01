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
  end
  
  def person
  end
  
  def get_recipients
    @bill = Bill.find_by_ident(params[:bill])
    
    @sens, @reps = Person.find_current_congresspeople_by_address_and_zipcode(params[:address], params[:zip])
    #Person.find_current_congresspeople_by_zipcode(params[:zip], nil)
    
    @reps = [] unless @reps.size == 1
    
    render :partial => 'contact/contact_recipients', :locals => { :show_checkboxes => true }
  end
  
  def letter
  end
  
  def showthread
    
    ## dont forget to check privacy settings
    
    @thread = Formageddon::FormageddonThread.find(params[:id])
    
    @page_title = "Letter to #{@thread.formageddon_recipient.name}"
  end
  
  def aftersend
    ## dont forget to check privacy settings
    unless params[:letter_ids].blank?
      letter_ids = params[:letter_ids].split(/,/)
      @letters = Formageddon::FormageddonLetter.find(letter_ids)
    end
    
    bill = Bill.find_by_ident(params[:bill])

    @letters.each do |l|  
      cclft = ContactCongressLettersFormageddonThread.find_by_formageddon_thread_id(l.formageddon_thread.id)
      if cclft.nil?
        if @contact_congress_letter.nil?
          @contact_congress_letter = ContactCongressLetter.new
          @contact_congress_letter.disposition = params[:disposition]
          @contact_congress_letter.bill = bill unless bill.nil?
          @contact_congress_letter.save
        end
        
        @contact_congress_letter.formageddon_threads << l.formageddon_thread
      else
        @contact_congress_letter = cclft.contact_congress_letter
        break
      end
    end
    
    if @contact_congress_letter.nil? 
      # something weird happened
      redirect_to '/'
      return
    else
      if @contact_congress_letter.user.nil?
        if current_user == :false
          user = create_new_user_from_formageddon_thread(@contact_congress_letter.formageddon_threads.first)
          @contact_congress_letter.user = user
        else
          @contact_congress_letter.user = current_user
        end
        @contact_congress_letter.save
        
        @new_user_notice = true
      else
        @new_user_notice = false
      end
    end
  end
  
  private
   
  def create_new_user_from_formageddon_thread(thread)
    return nil
  end
end
