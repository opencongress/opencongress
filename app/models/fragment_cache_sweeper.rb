module FragmentCacheSweeper
  # not really a sweeper, more of a deleter
  
  @@me = MemcacheExpiration.new
  
  def FragmentCacheSweeper.expire_commentary_fragments(object, type)
    fragments = []
  
    fragments << "#{object.fragment_cache_key}_#{type}_preview"
  
    pages, mod = object.send(type).size.divmod(Commentary.per_page)
    pages += 1 if mod > 0
    
    ['newest', 'oldest', 'toprated'].each do |srt|
      pages.times { |i| fragments << "#{object.fragment_cache_key}_#{type}_#{srt}_page_#{i}" }   
    end 
    
    expire_fragments(fragments)
  end
  
  
  def FragmentCacheSweeper.expire_fragments(memcached_fragments = [], squid_fragments = [])
    @@me.expire_frag(memcached_fragments)
    
    # squid stuff here
    
  end
end