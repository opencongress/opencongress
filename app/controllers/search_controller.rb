class SearchController < ApplicationController
  include ActionView::Helpers::TextHelper
    
  def index 
    @page_title = "Search OpenCongress"
  end
  
  def tips
    @page_title = "Search Tips"
  end
  
  def result
    @query = params[:q]
    @page = (params[:page] || 1).to_i
    @found_items = 0    
    @congresses = params[:search_congress] ? params[:search_congress].keys : ["#{DEFAULT_CONGRESS}"]
    
    unless @query
      flash.now[:notice] = "You didn't enter anything in the search field!"
    else
      query_stripped = prepare_tsearch_query(@query)
           
      if (query_stripped.size == 0)
        flash.now[:notice] = "You didn't enter anything meaningful into the search field!" 
      elsif (query_stripped.size < 4 && !query_stripped.to_i)
        flash.now[:notice] = "Your query must be longer than three characters!"
      else
        # save the search - but only once per session
        unless session[:searched_terms] and session[:searched_terms].index(@query)
          Search.create(:search_text => @query)
          session[:searched_terms] = "" unless session[:searched_terms]
          session[:searched_terms] += "#{@query} "
        end
                
        @search_bills = params[:search_bills] ? true : false
        @search_people = params[:search_people] ? true : false
        @search_committees = params[:search_committees] ? true : false
        @search_industries = false
        @search_issues = params[:search_issues] ? true : false
        @search_news = params[:search_news] ? true : false
        @search_blogs = params[:search_blogs] ? true : false
        @search_commentary = params[:search_commentary] ? true : false
        @search_comments = params[:search_comments] ? true : false
        @search_gossip_blog = params[:search_gossip_blog] ? true : false
      
        @search_commentary = false # temporary
        
        if (@search_bills)
          # first see if we match a bill's title exactly
          bill_titles = BillTitle.find(:all, :conditions => [ "UPPER(title)=?", query_stripped.upcase ])   
          bills_for_title = bill_titles.collect {|bt| bt.bill } 
          bills_for_title.uniq!

          # if we match only one, go right to that bill
          if bills_for_title.size == 1
            redirect_to bill_path(bills_for_title[0])
            return
          end
          
          @bills = Bill.full_text_search(query_stripped, { :page => @page, :congresses => @congresses })	  
          
          @found_items += @bills.total_entries
        end
        
        if (@search_people)
          people_for_name = Person.find(:all, 
                 :conditions => [ "(UPPER(firstname || ' ' || lastname)=? OR 
                                    UPPER(nickname || ' ' || lastname)=?)", 
                                    query_stripped.upcase, query_stripped.upcase ])  
                   
          if people_for_name.size == 1
            redirect_to person_url(people_for_name[0])
            return
          end
          
          @people = Person.full_text_search(query_stripped, { :page => @page, :only_current => true })              	  
          
          @found_items += @people.total_entries
        end
        
        if (@search_committees)
          @committees = Committee.full_text_search(query_stripped)
          @found_items += @committees_total = @committees.size

          
          @committees = @committees.sort_by { |c| [(c.name || ""), (c.subcommittee_name || "") ] }.group_by(&:name)
        end
      
        
        if (@search_issues)
          @issues = Subject.full_text_search(query_stripped, :page => @page)	  
          
          @found_items += @issues.total_entries
        end
        
        if (@search_comments)
          @comments = Comment.full_text_search(query_stripped, :page => @page)
                    
          @found_items += @comments.total_entries
        end
        
        if (@search_commentary || @search_news)
          @news = Commentary.full_text_search(query_stripped, { :page => @page, :commentary_type => 'news' })	  

          
          @found_items += @news.total_entries
        end
        
        if (@search_commentary || @search_blogs)
          @blogs = Commentary.full_text_search(query_stripped, { :page => @page, :commentary_type => 'blog' })	  
  
          @found_items += @blogs.total_entries
        end
        
        if (@search_gossip_blog)
          @articles = Article.full_text_search(query_stripped, :page => @page)	  
        
          @found_items += @articles.total_entries
        end
        
        if (@found_items == 0)
          if (@congresses == ["#{DEFAULT_CONGRESS}"])
            flash.now[:notice] = "Sorry, your search returned no results in the current #{DEFAULT_CONGRESS}th Congress."
          else
            flash.now[:notice] = "Sorry, your search returned no results."
          end
        end
      end
    end

  end
  
  def result_ajax
    result
    
    render :action => 'result', :layout => false
  end
  
  def autocomplete
    names = Person.find(:all, :conditions => "title='Rep.' OR title='Sen.'").collect{ |p| [p.popular_name, p.name, p] }

    bill_titles = []
    bills = Bill.find_hot_bills
    bills.each do |bill|
      bill_titles << [ bill.title_full_common, bill.title_full_common, bill ]
    end
     
    @people_hits = names.select{|h| h[0] =~ /#{params[:value]}/i }
    @bill_hits = bill_titles.select{|h| h[0] =~ /#{params[:value]}/i }

    render :layout => false
  end
  
  def popular
    @page = params[:page]
    @page = "1" unless @page
		@days = days_from_params(params[:days])
 		@searches = Search.top_search_terms(100,@days).paginate :page => @page
    @title_class = "sort"    
		@page_title = "Top Search Terms"
  end
end
