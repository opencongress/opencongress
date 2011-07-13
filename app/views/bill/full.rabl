attributes :bill_type, :number, :sponsor_id, :topresident_date, :last_vote_roll, :session, :topresident_datetime, :last_speech, :id, :page_views_count, :caption, :last_vote_date, :key_vote_category_id, :news_article_count, :summary, :blog_article_count, :last_vote_where, :plain_language_summary, :updated, :title_common, :title_full_common, :status, :typenumber, :last_action_at, :introduced_at, :ident

code(:permalink) { |b| bill_path(b) }

child :co_sponsors => :co_sponsors do
  extends "person/base"
end

child :sponsor => :sponsor do
  extends "person/base"
end

child :bill_titles do
  attributes :title_type, :as, :title, :is_default
end

child :most_recent_actions do
  attributes :action_type, :date, :datetime, :how, :where, :vote_type, :result, :amendment_id, :text, :roll_call_id, :roll_call_number, :created_at, :govtrack_order
end