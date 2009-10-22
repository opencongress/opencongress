ActionController::Routing::Routes.draw do |map|
  map.resources :mailing_list_items

  map.resources :watch_dogs

  map.resources :states do |s|
    s.resources :districts
  end

#  map.resources :wiki_links, :path_prefix => '/admin'

  map.resources :wiki_links, :path_prefix => '/admin'
  map.resource :political_notebook, :path_prefix => '/users/:login/profile', :collection => ['update_privacy'] do |notebook|
    notebook.resources :notebook_links, :collection => ['faceform', 'update']
    notebook.resources :notebook_videos
    notebook.resources :notebook_notes
    notebook.resources :notebook_files    
  end

  #  map.connect 'users/:login/profile/political_notebook/:action', :controller => 'notebook_items'
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connect '', :controller => 'index'
  map.home '', :controller => 'index', :action => 'index'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

  # Handle bill routing. The action determines what information about the bill will 
  # be displayed.
  map.connect 'bill/all', :controller => 'bill', :action => 'all'
  map.connect 'bill/pending', :controller => 'bill', :action => 'pending'
  map.connect 'bill/popular', :controller => 'bill', :action => 'popular'
  map.connect 'bill/hot', :controller => 'bill', :action => 'hot'
  map.connect 'bill/readthebill', :controller => 'bill', :action => 'readthebill'
  map.connect 'bill/readthebill.:format', :controller => 'bill', :action => 'readthebill'
  map.connect 'bill/compare', :controller => 'bill', :action => 'compare'
  map.connect 'bill/compare_by_issues', :controller => 'bill', :action => 'compare_by_issues'
  map.connect 'bill/hot_temp', :controller => 'bill', :action => 'hot_temp'
  map.connect 'bill/most/viewed', :controller => 'bill', :action => 'popular'  
  map.connect 'bill/most/:type', :controller => 'bill', :action => 'most_commentary'
  map.connect 'bill/atom_top20', :controller => 'bill', :action => 'atom_top20'
  map.connect 'bill/atom/most/viewed', :controller => 'bill', :action => 'atom_top20'
  map.connect 'bill/atom/most/:type', :controller => 'bill', :action => 'atom_top_commentary'
  map.connect 'bill/type/:bill_type', :controller => 'bill', :action => 'list_bill_type'
  map.connect 'bill/type/:bill_type/:page', :controller => 'bill', :action => 'list_bill_type'
  map.connect 'bill/text/status/:id', :controller => 'bill', :action => 'status_text'

  map.connect 'bill/:id/blogs/search', :controller => 'bill', :action => 'commentary_search', :commentary_type => 'blog'
  map.connect 'bill/:id/news/search', :controller => 'bill', :action => 'commentary_search', :commentary_type => 'news'
  map.connect 'bill/:id/blogs/search/:page', :controller => 'bill', :action => 'commentary_search', :commentary_type => 'blog'
  map.connect 'bill/:id/news/search/:page', :controller => 'bill', :action => 'commentary_search', :commentary_type => 'news'
  map.connect 'bill/:id/blogs/:page', :controller => 'bill', :action => 'blogs'
  map.connect 'bill/:id/news/:page', :controller => 'bill', :action => 'news'
  map.connect 'bill/upcoming/:id', :controller => 'bill', :action => 'upcoming'
  map.connect 'bill/:show_comments/:id/show', :controller => 'bill', :action => 'show'  
  map.connect 'bill/:id/:action', :controller => 'bill'
  map.connect 'bill/:id/:action.:format', :controller => 'bill'
  
  map.bill 'bill/:id/show', :controller => "bill", :action => "show"

  map.connect 'people/senators', :controller => 'people', :action => 'people_list', :person_type => 'senators'
  map.connect 'people/representatives', :controller => 'people', :action => 'people_list', :person_type => 'representatives'
  #map.connect 'person/senators', :controller => 'people', :action => 'people_list', :person_type => 'senators'
  #map.connect 'person/representatives', :controller => 'people', :action => 'people_list', :person_type => 'representatives'

  map.connect 'people/:person_type/most/:type', :controller => 'people', :action => 'most_commentary'
  map.connect 'people/:person_type/atom/most/:type', :controller => 'people', :action => 'atom_top_commentary'
  map.connect 'people/atom/featured', :controller => 'people', :action => 'atom_featured'


  map.connect 'people/:show_comments/show/:id', :controller => 'people', :action => 'show'
  map.connect 'people/wiki/:id', :controller => 'people', :action => 'wiki'
  map.connect 'people/comments/:id', :controller => 'people', :action => 'comments'
  map.connect 'people/news/:id/:page', :controller => 'people', :action => 'news'
  map.connect 'people/blogs/:id/:page', :controller => 'people', :action => 'blogs'

  map.connect 'people/voting_history/:id/:page', :controller => 'people', :action => 'voting_history'
  map.connect 'person/compare.:format', :controller => 'people', :action => 'compare'
  map.connect 'people/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id.:format', :controller => 'people'
  
  map.connect 'roll_call/text/summary/:id', :controller => "roll_call", :action => 'summary_text'
  
  map.connect 'admin', :controller => "admin/index"
  map.connect 'admin/stats/bills.:format', :controller => "admin/stats", :action => 'bills'
  
  map.connect 'battle_royale.:format', :controller => "battle_royale", :action => "index"
  map.connect 'battle_royale/:action.:format', :controller => "battle_royale"
  
  map.connect 'blog', :controller => "articles", :action => 'list'
  map.connect 'blog/:tag', :controller => "articles", :action => 'list'
  map.connect 'articles/view/:id', :controller => "articles", :action => "view" 
  map.connect 'articles/view/:show_comments/:id', :controller => "articles", :action => 'view' 
  map.connect 'articles/:id/atom', :controller => "articles", :action => 'article_atom'

  map.connect 'issues/:action/:id', :controller => 'issue'
  map.connect 'issue/:show_comments/show/:id', :controller => "issue", :action => "show"
  map.connect 'industry/:show_comments/show/:id', :controller => "industry", :action => "show"
  map.connect 'committee/:show_comments/show/:id', :controller => "committee", :action => "show"
 
  map.connect 'howtouse', :controller => 'about', :action => 'howtouse'

  map.connect 'login', :controller => 'account', :action => 'login'
  map.connect 'why', :controller => 'account', :action => 'why'
  map.connect 'logout', :controller => 'account', :action => 'logout'
  map.connect 'register', :controller => 'account', :action => 'signup'
  map.connect 'account/confirm/:login', :controller => "account", :action => "confirm"

  map.connect 'comments/all_comments/:object/:id', :controller => "comments", :action => "all_comments"
  map.connect 'comments/atom/:object/:id', :controller => 'comments', :action => "atom_comments"

  map.user_watchdog 'users/:login/profile/watchdog', :controller => "profile", :action => "watchdog"
  map.friends_import_contacts 'users/:login/profile/friends/import_contacts', :controller => "friends", :action => "import_contacts"
  map.friends_like_voters 'users/:login/profile/friends/like_voters', :controller => "friends", :action => "like_voters"
  map.friends_import_emails 'users/:login/profile/friends/invite_contacts', :controller => "friends", :action => "invite_contacts"
  map.friends_near_me 'users/:login/profile/friends/near_me', :controller => "friends", :action => "near_me"
  map.friends_add_confirm 'users/:login/profile/friends/confirm/:id', :controller => "friends", :action => "confirm"
  map.friends_add_deny 'users/:login/profile/friends/deny/:id', :controller => "friends", :action => "deny"
  map.friends_invite 'users/:login/profile/friends/invite', :controller => "friends", :action => "invite"
  map.friends_invite_form 'users/:login/profile/friends/invite_form', :controller => "friends", :action => "invite_form"
  map.resources :friends, :path_prefix => '/users/:login/profile'

  map.user_profile 'users/:login/profile', :controller => "profile", :action => "profile"
  map.user_profile_actions 'users/:login/profile/actions', :controller => "profile", :action => "actions"
  map.user_profile_items_tracked 'users/:login/profile/items_tracked', :controller => "profile", :action => "items_tracked"
  map.connect 'users/:login/profile/bills_supported', :controller => "profile", :action => "bills_supported"
  map.connect 'users/:login/profile/tracked_rss', :controller => "profile", :action => "tracked_rss"
  map.connect 'users/:login/profile/user_actions_rss', :controller => "profile", :action => "user_actions_rss"
  map.connect 'users/:login/profile/bills_supported/rss', :controller => "profile", :action => "bills_supported", :format => "rss"
  map.connect 'users/:login/profile/bills_opposed', :controller => "profile", :action => "bills_opposed"
  map.connect 'users/:login/profile/bills_opposed/rss', :controller => "profile", :action => "bills_opposed", :format => "rss"
  map.connect 'users/:login/profile/my_votes', :controller => "profile", :action => "my_votes"
  map.connect 'users/:login/profile/my_votes/rss', :controller => "profile", :action => "my_votes", :format => "rss"
  map.connect 'users/:login/profile/bills', :controller => "profile", :action => "bills"
  map.connect 'users/:login/profile/bills/rss', :controller => "profile", :action => "bills", :format => "rss"
  map.connect 'users/:login/profile/comments', :controller => "profile", :action => "comments"
  map.connect 'users/:login/profile/comments/rss', :controller => "profile", :action => "comments", :format => "rss"
  map.connect 'users/:login/profile/issues', :controller => "profile", :action => "issues"
  map.connect 'users/:login/profile/issues/rss', :controller => "profile", :action => "issues", :format => "rss"
  map.connect 'users/:login/profile/committees', :controller => "profile", :action => "committees"
  map.connect 'users/:login/profile/committees/rss', :controller => "profile", :action => "committees", :format => "rss"
  map.connect 'users/:login/profile/:person_type/rss', :controller => "profile", :action => "person", :format => "rss"
  map.connect 'users/:login/profile/:person_type', :controller => "profile", :action => "person"

  map.connect 'users/:login/feeds/:action', :controller => "user_feeds"
  map.connect 'users/:login/feeds/:action/:key', :controller => "user_feeds"
  
  map.connect 'video/rss', :controller => 'video', :action => 'all', :format => 'atom'

  map.connect 'bill/bill_vote/:bill/:id', :controller => "bill", :action => "bill_vote"
  map.connect 'vote/:year/:chamber/:number', :controller => "roll_call", :action => "by_number"
  map.connect 'users/:login/profile/political_notebook/:action', :controller => 'notebook_items'
  
#  map.connect 'users/:login/profile/political_notebook/new',  :controller => "notebook_items", :action => "new"               
#  map.connect 'users/:login/profile/political_notebook',      :controller => "notebook_items", :action => "index"

  # temporary home for api URLS
  map.connect 'api/bill/text_summary/:id', :controller => 'bill', :action => 'status_text'
  map.connect 'api/roll_call/text_summary/:id', :controller => "roll_call", :action => 'summary_text'  

  map.connect 'baucus_bill_health_care.html', :controller => 'index', :action => 's1796_redirect'
  map.connect 'tools/:action/:id', :controller => 'resources'
    
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  
  map.connect '*path', :controller => 'index', :action => 'notfound' unless ::ActionController::Base.consider_all_requests_local
  
end
