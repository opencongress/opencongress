class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "people", :id => false do |t| # from repstats/person.xml
      t.column "id", :integer
      t.column "firstname", :string
      t.column "middlename", :string
      t.column "lastname", :string
      t.column "nickname", :string
      t.column "birthday", :date
      t.column "gender", :string, :limit => 1
      t.column "religon", :string
      t.column "url", :string
      t.column "party", :string
      t.column "osid", :string
      t.column "bioguideid", :string
      t.column "title", :string
      t.column "state", :string
      t.column "district", :string
      t.column "name", :string # NOT redundant
      t.column "email", :string
      t.primary_key(id)
      # has_many :commitees, :through => :committee_people
      # has_many :commitee_people
      # has_many :bills, :through => :bill_sponsers
      # has_many :bill_sponsers
      # has_many :bills, :through => :bill_cosponsers
      # has_many :bill_cosponsers
      # belongs_to roles
    end
    
    create_table "roles" do |t| # from repstats/person.xml
      t.column "people_id", :integer
      t.column "type", :string
      t.column "startdate", :date
      t.column "enddate", :date
      t.column "party", :string
      t.column "state", :string
      t.column "district", :string
      t.column "url", :string
      t.column "address", :string
      t.column "phone", :string
      t.column "email", :string
    end

# Probably not required - use the subjects table
#    create_table "issue_areas" do |t|
#      t.column "name", :string
      # has_many bills
      # has_many commitees
#    end

    create_table "bills" do |t|
      # belongs to issue_areas
      # has_many :bill_titles
      # has_one :officialtitle, :class => :bill_title, :conditions => 'title_type = "official"'
      # has_many :sponsers, :through => :bill_sponsers
      # has_one :sponser, :class => :person, :foreign_key => "sponser_id"
      # has_many :co_sponsers, :through => :bill_cosponsers
      # has_many :bill_cosponsers
      # has_many :bill_actions
      # has_many :actions :through => :bill_actions
      # has_one :lastaction, :class => :action, :order => 'date DESC'
      # has_many :committees
      # has_many :relatedbills :through => :bill_relations
      # has_many :bills_relations
      # has_many :subjects
      # has_many :amendments, :order => :sequence
      t.column "session", :integer
      t.column "bill_type", :string, :limit => 2 # how short?
      t.column "number", :integer
      t.column "introduced", :integer # UNIX datetime
      t.column "sponser_id", :integer
      t.column "lastaction", :integer # UNIX datetime
      t.column "title", :string
      t.column "rolls", :string
      t.column "last_vote_date", :integer # UNIX datetime
      t.column "last_vote_where", :string # short
      t.column "last_vote_roll", :integer
      t.column "last_speech", :integer # UNIX datetime
      t.column "pl", :string # unknown contents
      t.column "topresident_date", :integer # UNIX datetime
      t.column "topresident_datetime", :date
      t.column "summary", :string
    end
    
    create_table "bill_titles" do |t| # from bills/bill-number.xml
      # belongs to bills
      t.column "title", :string
      t.column "title_type", :string
      t.column "as", :string
      t.column "bill_id", :integer
    end

    create_table "bills_cosponsers", :id => false do |t| # from bills/bill-number.xml
      # belongs to :bills
      # belongs_to :people
      t.column "person_id", :integer
      t.column "bill_id", :integer
    end

    create_table "bill_actions" do |t|
      # belongs to bills
      # belongs to actions
      t.column "bill_id", :integer
      t.column "action_id", :integer
    end

    create_table "actions" do |t| # from bills/bill-number.xml
      # has_one :bill_action
      # has_one roll # vote
      # has_many :refers
      t.column "action_type", :string # 'action' or 'vote' or 'calendar'
      t.column "date", :integer # UNIX datetime
      t.column "datetime", :datetime
      t.column "text", :string
      t.column "how", :string # vote
      t.column "where", :string # vote
      t.column "vote_type", :string # vote
      t.column "result", :string # vote
      t.column "bill_id", :integer
    end

    create_table "refers" do |t| # from actions
      # belongs_to :action
      t.column "label", :string
      t.column "ref", :string # Possible table ref e.g. CR H1515-1517 or CR H1515
      t.column "action_id", :integer
    end

    create_table "bills_relations", :id => false do |t|
      # belongs_to :related_bills, :class_name => :bills, :foreign_key => :related_bill_id
      # belongs_to :bills
      t.column "relation", :string
      t.column "bill_id", :integer
      t.column "related_bill_id", :integer
    end

    create_table "subjects" do |t|
      # belongs_to bills
      t.column "term", :string
      t.column "bill_id", :integer
    end

    create_table "amendments" do |t|
      # belongs_to :bill
      # has_many :amendment_actions
      # has_many :actions, :through => :amendment_actions
      # acts_as_list :scope => "bill_id"
      t.column "number", :string
      t.column "sequence", :integer
      t.column "retreived_date", :integer
      t.column "status", :string
      t.column "status_date", :integer
      t.column "status_datetime", :datetime
      t.column "offered_date", :integer
      t.column "offered_datetime", :datetime
      t.column "description", :string
      t.column "purpose", :string
      t.column "bill_id", :integer
    end

    create_table "commitees" do |t|
      # has_many :people, :through => :committee_people
      # has_many :committee_people
      # has_many :bills, :through => :bills_committees
      # has_many :bills_committees
      t.column "name", :string
      t.column "subcommittee_name", :string
    end

    create_table "bills_committees" do |t|
      t.column "bill_id", :integer
      t.column "committee_id", :integer
      t.column "activity", :string
    end

    create_table "committees_people" do |t|
      # belongs_to :committees
      # belongs_to :people
      t.column "committee_id", :integer
      t.column "person_id", :integer
    end
  end

  def self.down
    drop_table :people
    drop_table :roles
#    drop_table issue_areas
    drop_table :bills
    drop_table :bill_titles
    drop_table :bills_cosponsers
    drop_table :bill_actions
    drop_table :actions
    drop_table :refers
    drop_table :bills_relations
    drop_table :subjects
    drop_table :amendments
    drop_table :commitees
    drop_table :bills_commitees
    drop_table :committees_people
  end
end
