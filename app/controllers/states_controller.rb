class StatesController < ApplicationController
  # GET /states
  # GET /states.xml
  def index
    @page_title = "States"
    @states = State.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @states }
    end
  end

  # GET /states/1
  # GET /states/1.xml
  def show
    @state = State.find_by_abbreviation(params[:id])
    @page_title = "#{@state.name.titleize}"
    @representatives = @state.representatives.order(:district)
    @users = @state.users
    @tracking_suggestions = @state.tracking_suggestions
    @senators = Person.sen.find_all_by_state(@state.abbreviation).sort{|a,b| b.consecutive_years <=> a.consecutive_years }
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @state }
    end
  end

end
