ActiveRecord::Schema.define(:version => 1) do
  
  # Create tables for testing your plugin

   %w{blog_entries_profiles blog_entries blog_comments profiles}.each do |t|
     begin
       drop_table t
     rescue
     end
   end 
   
   create_table :blog_entries do |t|
     t.column :title,   :string
     t.column :description, :text
   end
    
   create_table :blog_comments do |t|
     t.column :blog_entry_id, :integer
     t.column :name,   :string
     t.column :email,   :string
     t.column :url,   :string
     t.column :comment, :text
   end

   create_table :profiles do |t|
     t.column :name,   :string
     t.column :public_info,   :string
     t.column :private_info,   :string
   end

   create_table :blog_entries_profiles, :id => false do |t|
     t.column :blog_entry_id, :integer
     t.column :profile_id, :integer
   end
end
