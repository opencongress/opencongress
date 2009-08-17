class SiteTextPage < ActiveRecord::Base
  belongs_to :page_text_editable, :polymorphic => true
end
