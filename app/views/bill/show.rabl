attributes :bill_type, :number, :sponsor_id, :topresident_date, :last_vote_roll, :session, :topresident_datetime, :last_speech, :id, :page_views_count, :caption, :last_vote_date, :introduced, :key_vote_category_id, :news_article_count, :summary, :blog_article_count, :last_vote_where, :plain_language_summary, :updated, :title_common, :title_full_common, :status, :typenumber, :last_action_at, :ident
code(:subjects) { |b| b.subjects.order('bill_count desc').collect { |s| s.term } }
code(:permalink) { |b| bill_path(b) }
