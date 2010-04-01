class Wiki < ActiveRecord::Base
  # This is not in app/models because it's not a real model.
  # But you could subclass this there if you wanted to use wiki tables in Rails.
  # eg. "class Page < Wiki" would use the wiki connection.
  require 'MediaCloth'
  require 'hpricot'
  
  establish_connection :oc_wiki

  set_table_name 'text'
  
  def self.summary_text_for(article_name)
    begin
      a = find_by_sql(['select rev_id, rev_timestamp, t.old_text, p.page_title, p.page_namespace from revision r, page p, text t where r.rev_id = p.page_latest and t.old_id = r.rev_text_id and page_title = ?', article_name])

      return nil if (a.nil? || a.empty?)
    
      # for some reason, newlines were messing up mediacloth
      no_newlines = a[0].old_text.gsub(/\n/, '')
      no_newlines =~ /\{\{Article summary\|(.*?)\}\}/

      if $~[1].blank?
        return nil
      else
        # remove the <ref> tags before returning
        doc = Hpricot(MediaCloth.wiki_to_html($~[1]))
        doc.search("ref").remove
      
        return doc.to_s
      end
    rescue
      return nil
    end
  end
end
