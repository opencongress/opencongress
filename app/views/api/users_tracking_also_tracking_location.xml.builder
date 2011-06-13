xml.instruct! :xml, :version=>"1.0" 

tracking_suggestions = obj.tracking_suggestions

xml.opencongress_users_tracking do |pt|
  
  pt << obj.to_xml(:skip_instruct => true)

  pt.tracking_people do |tp|
      tracking_suggestions[1][:my_people_tracked_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.tracking_bills do |tp|
      tracking_suggestions[1][:my_bills_tracked_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.tracking_issues do |tp|
      tracking_suggestions[1][:my_issues_tracked_facet].each do |p|
        tp << p[:object].to_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

end

