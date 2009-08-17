xml.instruct! :xml, :version=>"1.0" 
 
xml.comparison(:total_votes => @vote_together[1], :same_vote => @vote_together[0], :percentage => @vote_together[0].to_f / @vote_together[1].to_f) {
  


  
  xml.person1 {
   xml << @person1.to_xml(:skip_instruct => true)

  }
  
  xml.person2 {
    xml << @person2.to_xml(:skip_instruct => true)

  }

  xml.shared_committees {
    xml << @shared_committees.to_xml(:skip_instruct => true)
  }
  
  xml.hot_votes {
    @hot_votes.each do |hv|
      xml.vote {
        vo = hv[1].first
        xml << vo.to_xml(:skip_instruct => true, :include => {:bill => {:except => [:summary], :methods => [:ident, :title_full_common]}})
        xml << rc_compare(vo, true)     
      }
    end
  }

  xml.other_votes {
    @cold_votes.each do |hv|
      xml.vote {
        vo = hv[1].first
        xml << vo.to_xml(:skip_instruct => true, :include => [:bill])
        xml << rc_compare(vo, true)     
      }
    end
  }

}

