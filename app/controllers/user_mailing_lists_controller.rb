class UserMailingListsController < ApplicationController

  def index
    @user_mailing_lists = UserMailingList.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_mailing_lists }
    end
  end

  # GET /user_mailing_lists/1
  # GET /user_mailing_lists/1.xml
  def show
    @user_mailing_list = UserMailingList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_mailing_list }
    end
  end

  # GET /user_mailing_lists/new
  # GET /user_mailing_lists/new.xml
  def new
    @user_mailing_list = UserMailingList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_mailing_list }
    end
  end

  # GET /user_mailing_lists/1/edit
  def edit
    @user_mailing_list = UserMailingList.find(params[:id])
  end

  # POST /user_mailing_lists
  # POST /user_mailing_lists.xml
  def create
    @user_mailing_list = UserMailingList.new(params[:user_mailing_list])

    respond_to do |format|
      if @user_mailing_list.save
        flash[:notice] = 'UserMailingList was successfully created.'
        format.html { redirect_to(@user_mailing_list) }
        format.xml  { render :xml => @user_mailing_list, :status => :created, :location => @user_mailing_list }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @user_mailing_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_mailing_lists/1
  # PUT /user_mailing_lists/1.xml
  def update
    @user_mailing_list = UserMailingList.find(params[:id])

    respond_to do |format|
      if @user_mailing_list.update_attributes(params[:user_mailing_list])
        flash[:notice] = 'UserMailingList was successfully updated.'
        format.html { redirect_to(@user_mailing_list) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user_mailing_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_mailing_lists/1
  # DELETE /user_mailing_lists/1.xml
  def destroy
    @user_mailing_list = UserMailingList.find(params[:id])
    @user_mailing_list.destroy

    respond_to do |format|
      format.html { redirect_to(user_mailing_lists_url) }
      format.xml  { head :ok }
    end
  end
end
