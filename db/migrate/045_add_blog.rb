class AddBlog < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.column :commentable_id,   :integer
      t.column :commentable_type, :string
      t.column :comment,          :text
      t.column :user_id,          :integer
      t.column :name,             :string
      t.column :email,            :string
      t.column :homepage,         :string
      t.column :created_at,       :datetime
      t.column :parent_id,        :integer
    end
    add_index :comments, [:commentable_id, :commentable_type]
    
    create_table :articles, :force => true do |t|
      t.column :title,          :string
      t.column :article,        :text
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :published_flag, :boolean
      t.column :frontpage,      :boolean, :default => false
      t.column :user_id,        :integer
      t.column :render_type,    :string
    end
    add_index :articles, :created_at

    create_table :taggings, :force => true do |t|
      t.column :tagg_id,        :integer
      t.column :taggable_id,   :integer
      t.column :taggable_type, :string
    end
    add_index :taggings, :tagg_id
    add_index :taggings, [:taggable_id, :taggable_type]
    
    create_table :taggs, :force => true do |t|
      t.column :name, :string
    end
    
    add_column :users, :blog_author, :boolean, :default => false
    add_column :users, :full_name, :string
    
    gossip = Gossip.find(:all)
    
    # set gossip owner to donny
    gossip_owner = User.find(:first, :conditions => "login = 'donny'")
    
    gossip.each do |g|
      Article.transaction do
        new_article = Article.new
      
        new_article.title = g.title
        new_article.article = g.tip
        new_article.created_at = g.created_at
        new_article.published_flag = g.approved
        new_article.frontpage = g.frontpage
        new_article.render_type = 'html'
        new_article.user_id = gossip_owner.id
        
        new_article.save
      end
      
      g.destroy
    end
  end

  def self.down
    drop_table :comments
    drop_table :articles
    drop_table :taggings
    drop_table :taggs
    
    remove_column :users, :blog_author
    remove_column :users, :full_name
  end
end
