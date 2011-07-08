collection @bills => :bills

extends "bill/full"


# {:except => [:rolls, :hot_bill_category_id],
#                          :methods => [:title_full_common, :status],
#                          :include => {:co_sponsors => {:methods => [:oc_user_comments, :oc_users_tracking]},
#                                       :sponsor => {:methods => [:oc_user_comments, :oc_users_tracking]},
#                                       :bill_titles => {},
#                                       :most_recent_actions => {}
#                                       }}}