class FeaturedPersonSweeper < ActionController::Caching::Sweeper
   observe FeaturedPerson

   def after_save(record)
     expire_fragment("frontpage_featured_senator")
     expire_fragment("frontpage_featured_representative")
   end
 end