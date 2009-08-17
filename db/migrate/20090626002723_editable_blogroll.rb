class EditableBlogroll < ActiveRecord::Migration
  def self.up
    a = Article.new
    a.title = '***BLOGROLL***'
    a.published_flag = false
    a.frontpage = false    
    a.article = "<li><a href='http://blog.washingtonpost.com/capitol-briefing/'>Capitol Briefing</a> </li>
    <li><a href='http://thecaucus.blogs.nytimes.com/'>The Caucus</a> </li>
    <li><a href='http://www.prwatch.org/blog/2307/'>Congresspedia</a> </li>
    <li><a href='http://corner.nationalreview.com/'>The Corner</a> </li>
    <li><a href='http://www.crooksandliars.com/'>Crooks and Liars</a> </li>
    <li><a href='http://www.politico.com/blogs/thecrypt/'>The Crypt</a></li>
    <li><a href='http://dailykos.com/'>Daily Kos</a> </li>
    <li><a href='http://bobgeiger.blogspot.com/'>Bob Geiger</a> </li>
    <li><a href='http://www.salon.com/opinion/greenwald/'>Glenn Greenwald</a> </li>
    <li><a href='http://hotair.com/'>Hot Air</a> </li>
    <li><a href='http://www.huffingtonpost.com/'>Huffington Post</a> </li>
    <li><a href='http://pajamasmedia.com/instapundit/'>Instapundit</a> </li>
    <li><a href='http://www.slate.com/kausfiles/'>Kausfiles</a> </li>
    <li><a href='http://mydd.com/'>My DD</a> </li>
    <li><a href='http://www.ombwatch.org/'>OMB Watch</a> </li>
    <li><a href='http://www.theopenhouseproject.com/'>Open House Project</a> </li>
    <li><a href='http://openleft.com/'>Open Left</a> </li>
    <li><a href='http://washingtonmonthly.com/'>Political Animal</a> </li>
    <li><a href='http://politicalticker.blogs.cnn.com/'>Political Ticker</a> </li>
    <li><a href='http://www.powerlineblog.com/'>Power Line</a> </li>
    <li><a href='http://www.realclearpolitics.com/'>Real Clear Politics</a> </li>
    <li><a href='http://realtime.sunlightprojects.org/'>Real Time Investigations</a> </li>
    <li><a href='http://www.redstate.com/'>RedState</a> </li>
    <li><a href='http://senatus.wordpress.com/'>Senatus</a> </li>
    <li><a href='http://andrewsullivan.theatlantic.com/the_daily_dish/'>Andrew Sullivan</a> </li>
    <li><a href='http://www.time-blog.com/swampland/'>Swampland</a> </li>
    <li><a href='http://talkingpointsmemo.com/'>Talking Points Memo</a> </li>
    <li><a href='http://blog.heritage.org/'>The Foundry</a> </li>
    <li><a href='http://www.washingtonindependent.com/'>The Washington Independent</a> </li>
    <li><a href='http://yglesias.thinkprogress.org/'>Matthew Yglesias</a> </li>"
    
    u = User.find_by_login('donnyshaw')
    a.user = u
    
    # set the date way in the past so it appears at the bottom of the admin list
    a.created_at = (Date.today - 10.years)

    a.save
  end

  def self.down
    a = Article.find_by_title("***BLOGROLL***")
    a.destroy
  end
end
