class AggregateTriggerFix < ActiveRecord::Migration
  def self.up
    execute "drop TRIGGER aggregate_comment_trigger  ON comments"
    execute "drop TRIGGER aggregate_bookmark_trigger  ON bookmarks"
    execute "drop TRIGGER aggregate_bill_votes_trigger  ON bill_votes"
    execute "drop TRIGGER aggregate_commentaries_trigger  ON commentaries"

    execute "CREATE TRIGGER aggregate_comment_trigger AFTER INSERT ON comments FOR EACH ROW EXECUTE PROCEDURE aggregate_increment()"
    execute "CREATE TRIGGER aggregate_bookmark_trigger AFTER INSERT ON bookmarks FOR EACH ROW EXECUTE PROCEDURE aggregate_increment()"
    execute "CREATE TRIGGER aggregate_bill_votes_trigger AFTER INSERT ON bill_votes FOR EACH ROW EXECUTE PROCEDURE aggregate_increment()"
    execute "CREATE TRIGGER aggregate_commentaries_trigger AFTER INSERT ON commentaries FOR EACH ROW EXECUTE PROCEDURE aggregate_increment()"
  end

  def self.down
  end
end
