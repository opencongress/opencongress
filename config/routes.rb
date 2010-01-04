ActionController::Routing::Routes.draw do |map|
  map.resources :mailing_list_items
  map.resources :watch_dogs

  map.resources :states do |s|
    s.resources :districts
  end

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
  # map.connect '', :controller => 'welcome'
  map.connect '', :controller => 'index'
  map.home '', :controller => 'index', :action => 'index'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

  # Handle bill routing. The action determines what information about the bill will 
  # be displayed.
  map.users_tracking_bill 'bill/:id/users_tracking', :controller => 'friends', :action => 'tracking_bill'
  map.users_tracking_bill_by_state 'bill/:id/users_tracking/:state', :controller => 'friends', :action => 'tracking_bill', :state => /\w{2}/

  map.with_options :controller => 'bill' do |b|
    b.connect 'bill/all', :action => 'all'
    b.connect 'bill/pending', :action => 'pending'
    b.connect 'bill/popular', :action => 'popular'
    b.connect 'bill/hot', :action => 'hot'
    b.connect 'bill/readthebill', :action => 'readthebill'
    b.connect 'bill/readthebill.:format', :action => 'readthebill'
    b.connect 'bill/compare', :action => 'compare'
    b.connect 'bill/compare_by_issues', :action => 'compare_by_issues'
    b.connect 'bill/hot_temp', :action => 'hot_temp'
    b.connect 'bill/most/viewed', :action => 'popular'  
    b.connect 'bill/most/:type', :action => 'most_commentary'
    b.connect 'bill/atom_top20', :action => 'atom_top20'
    b.connect 'bill/atom/most/viewed', :action => 'atom_top20'
    b.connect 'bill/atom/most/:type', :action => 'atom_top_commentary'
    b.connect 'bill/type/:bill_type', :action => 'list_bill_type'
    b.connect 'bill/type/:bill_type/:page', :action => 'list_bill_type'
    b.connect 'bill/text/status/:id', :action => 'status_text'
    b.connect 'bill/:id/blogs/search', :action => 'commentary_search', :commentary_type => 'blog'
    b.connect 'bill/:id/news/search', :action => 'commentary_search', :commentary_type => 'news'
    b.connect 'bill/:id/blogs/search/:page', :action => 'commentary_search', :commentary_type => 'blog'
    b.connect 'bill/:id/news/search/:page', :action => 'commentary_search', :commentary_type => 'news'
    b.blogs_bill 'bill/:id/blogs', :action => 'blogs'
    b.news_bill 'bill/:id/news', :action => 'news'
    b.connect 'bill/:id/blogs/:page', :action => 'blogs'
    b.connect 'bill/:id/news/:page', :action => 'news'
    b.connect 'bill/upcoming/:id', :action => 'upcoming'
    b.connect 'bill/:show_comments/:id/show', :action => 'show'  
    b.connect 'bill/bill_vote/:bill/:id', :action => 'bill_vote'
    b.bill 'bill/:id/show', :action => 'show'
    b.connect 'bill/:id/:action'
    b.connect 'bill/:id/:action.:format'
  end

  map.with_options :controller => 'people' do |p|
    p.connect 'people/senators', :action => 'people_list', :person_type => 'senators'
    p.connect 'people/representatives', :action => 'people_list', :person_type => 'representatives'
    p.connect 'people/:person_type/most/:type', :action => 'most_commentary'
    p.connect 'people/:person_type/atom/most/:type', :action => 'atom_top_commentary'
    p.connect 'people/atom/featured', :action => 'atom_featured'

    p.connect 'people/:show_comments/show/:id', :action => 'show'
    p.connect 'people/wiki/:id', :action => 'wiki'
    p.connect 'people/comments/:id', :action => 'comments'
    p.news_person 'people/news/:id', :action => 'news'
    p.blogs_person 'people/blogs/:id', :action => 'blogs'
    p.connect 'people/news/:id/:page', :action => 'news'
    p.connect 'people/blogs/:id/:page', :action => 'blogs'

    p.connect 'people/voting_history/:id/:page', :action => 'voting_history'
    p.connect 'person/compare.:format', :action => 'compare'
    p.person  'person/show/:id', :action => 'show'
    p.connect 'people/:action/:id'
    p.connect 'person/:action/:id'
    p.connect 'person/:action/:id.:format'
  end

  map.connect 'roll_call/text/summary/:id', :controller => 'roll_call', :action => 'summary_text'

  map.admin 'admin', :controller => 'admin/index'
  map.connect 'admin/stats/bills.:format', :controller => 'admin/stats', :action => 'bills'

  map.with_options :controller => 'battle_royale' do |br|
    br.battle_royale 'battle_royale.:format',  :action => 'index'
    br.connect 'battle_royale/:action.:format'
  end
  
  map.with_options :controller => 'articles' do |a|
    a.blog 'blog', :action => 'list'
    a.connect 'blog/:tag', :action => 'list'
    a.article 'articles/view/:id', :action => 'view'
    a.connect 'articles/view/:show_comments/:id', :action => 'view' 
    a.connect 'articles/:id/atom', :action => 'article_atom'
  end

  map.with_options :controller => 'issue' do |i|
    i.issues 'issues'
    i.issue 'issues/show/:id', :action => 'show'
    i.connect 'issue/:show_comments/show/:id', :action => 'show'
  end

  map.connect 'industry/:show_comments/show/:id', :controller => 'industry', :action => 'show'
  map.connect 'committee/:show_comments/show/:id', :controller => 'committee', :action => 'show'
  map.connect 'issues/:action/:id', :controller => 'issue'
 
  map.connect 'howtouse', :controller => 'about', :action => 'howtouse'

  map.with_options :controller => 'account' do |a|
    a.login 'login', :action => 'login'
    a.connect 'why', :action => 'why'
    a.logout 'logout', :action => 'logout'
    a.signup 'register', :action => 'signup'
    a.welcome 'welcome', :action => 'welcome'
    a.confirmation 'account/confirm/:login', :action => 'confirm'
  end

  map.with_options :controller => 'comments' do |c|
    c.connect 'comments/all_comments/:object/:id', :action => 'all_comments'
    c.connect 'comments/atom/:object/:id', :action => 'atom_comments'
  end
  
  map.with_options :controller => 'friends' do |fr|
    fr.friends_import_contacts 'users/:login/profile/friends/import_contacts', :action => 'import_contacts'
    fr.friends_like_voters 'users/:login/profile/friends/like_voters', :action => 'like_voters'
    fr.friends_import_emails 'users/:login/profile/friends/invite_contacts', :action => 'invite_contacts'
    fr.friends_near_me 'users/:login/profile/friends/near_me', :action => 'near_me'
    fr.friends_add_confirm 'users/:login/profile/friends/confirm/:id', :action => 'confirm'
    fr.friends_add_deny 'users/:login/profile/friends/deny/:id', :action => 'deny'
    fr.friends_invite 'users/:login/profile/friends/invite', :action => 'invite'
    fr.friends_invite_form 'users/:login/profile/friends/invite_form', :action => 'invite_form'
  end
  
  map.resources :friends, :path_prefix => '/users/:login/profile'

  map.with_options :controller => 'profile' do |p|
    p.user_profile 'users/:login/profile', :action => 'show'
    p.user_profile_actions 'users/:login/profile/actions', :action => 'actions'
    p.user_profile_items_tracked 'users/:login/profile/items_tracked', :action => 'items_tracked'
    p.user_watchdog 'users/:login/profile/watchdog', :action => 'watchdog'
    p.connect 'users/:login/profile/bills_supported', :action => 'bills_supported'
    p.connect 'users/:login/profile/tracked_rss', :action => 'tracked_rss'
    p.connect 'users/:login/profile/user_actions_rss', :action => 'user_actions_rss'
    p.connect 'users/:login/profile/bills_supported/rss', :action => 'bills_supported', :format => "rss"
    p.connect 'users/:login/profile/bills_opposed', :action => 'bills_opposed'
    p.connect 'users/:login/profile/bills_opposed/rss', :action => 'bills_opposed', :format => "rss"
    p.connect 'users/:login/profile/my_votes', :action => 'my_votes'
    p.connect 'users/:login/profile/my_votes/rss', :action => 'my_votes', :format => "rss"
    p.connect 'users/:login/profile/bills', :action => 'bills'
    p.connect 'users/:login/profile/bills/rss', :action => 'bills', :format => "rss"
    p.connect 'users/:login/profile/comments', :action => 'comments'
    p.connect 'users/:login/profile/comments/rss', :action => 'comments', :format => "rss"
    p.connect 'users/:login/profile/issues', :action => 'issues'
    p.connect 'users/:login/profile/issues/rss', :action => 'issues', :format => "rss"
    p.connect 'users/:login/profile/committees', :action => 'committees'
    p.connect 'users/:login/profile/committees/rss', :action => 'committees', :format => "rss"
    p.connect 'users/:login/profile/:person_type/rss', :action => 'person', :format => "rss"
    p.connect 'users/:login/profile/:person_type', :action => 'person'
  end

  map.connect 'users/:login/feeds/:action', :controller => 'user_feeds'
  map.connect 'users/:login/feeds/:action/:key', :controller => 'user_feeds'
  
  map.connect 'video/rss', :controller => 'video', :action => 'all', :format => 'atom'
  
  map.with_options :controller => 'roll_call', :action => 'by_number',
                    :year => /\d{4}/, :chamber => /[hs]/, :number => /\d+/ do |rc|
    rc.connect 'vote/:year/:chamber/:number'
    rc.connect "vote/:year/:chamber/:number/:state", :state => /\w{2}/
  end

  map.connect 'users/:login/profile/political_notebook/:action', :controller => 'notebook_items'

  map.connect 'tools/:action/:id', :controller => 'resources'
  map.tools 'tools', :controller => 'resources'

  # Temporary home for api URLS
  map.api 'api', :controller => 'api', :action => 'index'
  map.connect 'api/bill/text_summary/:id', :controller => 'bill', :action => 'status_text'
  map.connect 'api/roll_call/text_summary/:id', :controller => 'roll_call', :action => 'summary_text'  

  # Temporary routes for health care legislation
  map.connect 'baucus_bill_health_care.html', :controller => 'index', :action => 's1796_redirect'
  map.connect 'senate_health_care_bill', :controller => 'bill', :action => 'text', :id => '111-h3590', :version => 'ocas'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  
  map.connect '*path', :controller => 'index', :action => 'notfound' unless ::ActionController::Base.consider_all_requests_local
  
  Jammit::Routes.draw(map)
end
