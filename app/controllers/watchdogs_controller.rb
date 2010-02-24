class WatchdogsController < ApplicationController

  def index
    @page_title = "Watchdog Congress"
    @include_vids_styles = true
    @watchdogs = WatchDog.find(:all)
    @watchdog_ids = @watchdogs.collect{|p| p.user_id}
    @i_count = NotebookItem.count(:id, :include => [:political_notebook],
                                     :conditions => ["political_notebooks.user_id in (?)", @watchdog_ids],
                                     :group => ["political_notebooks.user_id"])

    logger.info @i_count.to_yaml
    @items = NotebookItem.find(:all, :include => [:political_notebook], 
                                     :conditions => ["political_notebooks.user_id in (?)", @watchdog_ids], 
                                     :order => "notebook_items.created_at desc",
                                     :limit => 30)
    @item_comments = Comment.find_by_sql(["SELECT n1.* FROM comments AS n1
                                       LEFT OUTER JOIN comments as n2 ON (n1.user_id = n2.user_id AND (n1.created_at < n2.created_at OR (n1.created_at = n2.created_at AND n1.id < n2.id))) WHERE n1.user_id in (?) GROUP BY n1.id, n1.commentable_id, n1.commentable_type, n1.comment, n1.user_id, n1.name, n1.email, n1.homepage, n1.created_at, n1.parent_id, n1.title, n1.updated_at, n1.average_rating, n1.censored, n1.ok, n1.rgt, n1.lft, n1.root_id, n1.fti_names, n1.flagged, n1.ip_address HAVING COUNT(*) < 3 ORDER BY n1.created_at desc LIMIT 30;", @watchdog_ids])
                                       
    logger.info @item_comments.to_yaml
                                                                        
    @items = NotebookItem.find_by_sql(["SELECT n1.* FROM notebook_items AS n1
                                       INNER JOIN political_notebooks on political_notebooks.id = n1.political_notebook_id
                                       LEFT OUTER JOIN notebook_items AS n2 ON (n1.political_notebook_id = n2.political_notebook_id 
                                      AND (n1.created_at < n2.created_at OR (n1.created_at = n2.created_at AND n1.id < n2.id)))
                                      WHERE political_notebooks.user_id in (?) 
                                      GROUP BY n1.id, n1.political_notebook_id, n1.type, n1.url, n1.title, n1.date, n1.source, 
                                               n1.description, n1.is_internal, n1.embed, n1.created_at, n1.updated_at, n1.parent_id, 
                                               n1.size, n1.width, n1.height, n1.filename, n1.content_type, n1.thumbnail, n1.notebookable_type, 
                                               n1.notebookable_id, n1.hot_bill_category_id 
                                      HAVING COUNT(*) < 3
                                      ORDER BY n1.created_at desc
                                      LIMIT 50;", @watchdog_ids])
     @items = @items.concat(@item_comments).sort {|b,a| a.created_at <=> b.created_at}

     @watchdogs = WatchDog.find(:all, :include => [:user, {:district => :state}], :order => "states.abbreviation asc, districts.district_number asc")
  end

  def find
    @districts = ZipcodeDistrict.from_address(params[:address])
    render :partial => "find_results"
  end

end
