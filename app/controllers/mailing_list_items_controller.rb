class MailingListItemsController < ApplicationController

  before_filter :login_required
  before_filter :get_user_mailing_list

  # GET /mailing_list_items
  # GET /mailing_list_items.xml
  def index
    mailing_list_items = @user_ml.mailing_list_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mailing_list_items }
    end
  end

  # GET /mailing_list_items/1
  # GET /mailing_list_items/1.xml
  def show
    mailing_list_item = @user_ml.mailing_list_items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mailing_list_item }
    end
  end

  # GET /mailing_list_items/new
  # GET /mailing_list_items/new.xml
  def new
    @mailing_list_item = @user_ml.mailing_list_items.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mailing_list_item }
    end
  end

  # GET /mailing_list_items/1/edit
  def edit
    @mailing_list_item = @user_ml.mailing_list_items.find(params[:id])
  end

  # POST /mailing_list_items
  # POST /mailing_list_items.xml
  def create
    @mailing_list_item = @user_ml.mailing_list_items.find_or_initialize_by_mailable_type_and_mailable_id(params[:mailing_list_item][:mailable_type],params[:mailing_list_item][:mailable_id])

    respond_to do |format|
      if @mailing_list_item.save
        format.html {
          flash[:notice] = 'Email alert was successfully created.'
          redirect_to(@mailing_list_item)
        }
        format.js { render :text => "Added to Email Alerts" }
        format.xml  { render :xml => @mailing_list_item, :status => :created, :location => @mailing_list_item }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @mailing_list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mailing_list_items/1
  # PUT /mailing_list_items/1.xml
  def update
    @mailing_list_item = @user_ml.mailing_list_items.find(params[:id])

    respond_to do |format|
      if @mailing_list_item.update_attributes(params[:mailing_list_item])
        flash[:notice] = 'MailingListItem was successfully updated.'
        format.html { redirect_to(@mailing_list_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @mailing_list_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mailing_list_items/1
  # DELETE /mailing_list_items/1.xml
  def destroy
    @mailing_list_item = @user_ml.mailing_list_items.find(params[:id])
    @mailing_list_item.destroy

    respond_to do |format|
      format.html { redirect_to(user_profile_items_tracked(current_user.login)) }
      format.xml  { head :ok }
    end
  end

  def get_user_mailing_list
     @user_ml = current_user.user_mailing_list
     if @user_ml.nil?
        @user_ml = UserMailingList.create({:status => UserMailingList::OK, :user_id => current_user.id})
     end
  end

end
