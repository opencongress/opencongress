class ArticleImage < ActiveRecord::Base
  belongs_to :article

  mount_uploader :image, ArticleImageUploader
  validates_presence_of :image
  validates_integrity_of :image
  validates_processing_of :image

end
