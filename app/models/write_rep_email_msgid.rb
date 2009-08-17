class WriteRepEmailMsgid < ActiveRecord::Base
  belongs_to :write_rep_email
  belongs_to :person
end