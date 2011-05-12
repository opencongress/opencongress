OpenCongress::Application.routes.draw do
  resources :mailing_list_items
  resources :watch_dogs

  resources :states do
    resources :districts
  end

  match '/' => 'index#index', :as => :home

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # match ':controller/service.wsdl' => 'wsdl'

  # Handle bill routing. The action determines what information about the bill will 
  # be displayed.
  match 'bill/:id/users_tracking' => 'friends#tracking_bill', :as => :users_tracking_bill
  match 'bill/:id/users_tracking/:state' => 'friends#tracking_bill', :state => /\w{2}/, :as => :users_tracking_bill_by_state

  scope 'bill', :controller => 'bill' do
    for action in %w{ all pending popular major hot readthebill compare compare_by_issues atom_top20 }
      match action, :action => action, :as => 'bill_' + action
    end

    match 'most/:type', :action => 'most_commentary'
    match 'most/viewed', :action => 'popular'
    match 'atom/most/viewed', :action => 'atom_top20'
    match 'atom/most/:type', :action => 'atom_top_commentary', :as => :bill_most_commentary
    match 'type/:bill_type(/:page)', :action => 'list_bill_type'
    match 'text/status/:id', :action => 'status_text'
    match 'upcoming/:id', :action => 'upcoming'
    match 'bill_vote/:bill/:id', :action => 'bill_vote'

    scope ':id' do
      match 'blogs(/:page)', :action => 'blogs', :as => :blogs_bill
      match 'blogs/search(/:page)', :action => 'commentary_search', :commentary_type => 'blog'        
      match 'news(/:page)', :action => 'news', :as => :news_bill
      match 'news/search(/:page)', :action => 'commentary_search', :commentary_type => 'news'        
      match 'text', :action => 'text', :as => :bill_text
      match 'comments', :action => 'comments', :as => :bill_comments
      match 'show', :action => 'show', :as => :bill
      match ':action'
    end
    
    match ':id' => 'bill#show'

  end
  match 'bill' => redirect('/bill/all')

  scope 'people', :controller => 'people' do
    match 'senators', :action => 'people_list', :person_type => 'senators'
    match 'representatives', :action => 'people_list', :person_type => 'representatives'
    match ':person_type/most/:type', :action => 'most_commentary'
    match ':person_type/atom/most/:type', :action => 'atom_top_commentary'
    match 'atom/featured', :action => 'atom_featured'
    match 'wiki/:id', :action => 'wiki'
    match 'comments/:id', :action => 'comments'
    match 'news/:id(/:page)', :action => 'news', :as => :news_person
    match 'blogs/:id(/:page)', :action => 'blogs', :as => :blogs_person
    match 'votes_with_party/:chamber/:party', :action => 'votes_with_party'
    match 'voting_history/:id/:page', :action => 'voting_history'
    match 'compare.:format', :action => 'compare'
    match 'show/:id', :action => 'show', :as => 'person'
  end
  
  scope 'person', :controller => 'people' do
    match 'show/:id', :action => 'show'
    match 'atom/:id', :action => 'show'
  end
  

  match 'admin' => 'admin#index'


  namespace :admin do
     resources :wiki_links, :pvs_category_mappings

     match '/' => 'index#index', :as => 'admin'

     scope 'stats', :controller => 'stats' do
       match 'bills.:format', :action => 'bills'
       match 'partner_email.:format', :action => 'partner_email'
     end
  end

  match 'battle_royale' => 'battle_royale#index'
  match 'battle_royale/:action', :controller => 'battle_royale'

  match 'blog(/:tag)' => 'articles#list', :as => :blogs
  
  scope 'articles', :controller => 'articles' do
    match 'view/:id', :action => 'view', :as => :article
    match ':id/atom', :action => 'article_atom'
  end

  match 'issues' => 'issue#index'

  scope 'issues', :controller => 'issue' do
    match 'show/:id', :action => 'show', :as => :issue
    match ':action/:id'
  end
  
  match 'howtouse' => 'about#howtouse'
  
  scope :controller => 'account' do
    for action in %w{ login why logout signup welcome }
      match action, :action => action
    end
    
    match 'register', :action => 'signup'
    match 'account/confirm/:login', :action => 'confirm'
  end

  scope :controller => 'comments' do
    match 'comments/all_comments/:object/:id', :action => 'all_comments'
    match 'comments/atom/:object/:id', :action => 'atom_comments'
  end

  match 'users/:login/profile' => 'profile#show', :as => :user_profile

  scope 'users/:login' do

    scope 'profile' do 
      resource :political_notebook do
        collection do
          post :update_privacy
        end
        resources :notebook_links do
          collection do
            get :faceform
          end
        end
        resources :notebook_videos
        resources :notebook_notes
        resources :notebook_files    
      end
    
      scope 'friends', :controller => 'friends' do
        for action in %w{ import_contacts like_voters invite_contacts near_me invite invite_form }
          match action, :action => action, :as => 'friends_' + action
        end

        for action in %w{ confirm deny } do
          match action + '/:id', :action => action, :as => 'friends_add_' + action
        end
      end
  
      resources :friends

      scope :controller => 'profile' do
        for action in %w{ actions items_tracked watchdog edit_profile bills_supported tracked_rss user_actions_rss bills_opposed my_votes bills comments issues committees } do
          match action, :action => action, :as => 'user_' + action
        end

        match ':person_type', :action => 'person'
      end
    end # profile
    
    match 'feeds/:action(/:key)', :controller => 'user_feeds'
    
  end # users/:login

  match 'video/rss' => 'video#all', :format => 'atom'

  scope :controller => 'roll_call' do
    match 'roll_call/text/summary/:id', :action => 'summary_text'      
    match 'vote/:year/:chamber/:number(/:state)', :action => 'by_number', :year => /\d{4}/, :chamber => /[hs]/, :number => /\d+/, :state => /\w{2}/
  end

  match 'tools(/:action/:id)', :controller => 'resources', :as => 'tools'

  # API
  match 'api' => 'api#index'
  match 'api/bill/text_summary/:id' => 'bill#status_text'
  match 'api/roll_call/text_summary/:id' => 'roll_call#summary_text'

  # Temporary routes for health care legislation
  match 'baucus_bill_health_care.html' => 'index#s1796_redirect'
  match 'presidents_health_care_proposal' => 'index#presidents_health_care_proposal'
  match 'senate_health_care_bill' => 'bill#text', :id => '111-h3590', :version => 'ocas'
  match 'house_reconciliation' => 'index#house_reconciliation'

  match ':controller(/:action(/:id))'
  #match '*path' => 'index#notfound' #unless Rails.application.config.consider_all_requests_local
  
end  
