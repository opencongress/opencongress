xml.instruct! :xml, :version=>"1.0" 
 
xml.opencongress_users_tracking do |pt|
  
  pt << @object.to_light_xml(:skip_instruct => true)
  pt.users_opposing(@opposing_suggestions[0])
  pt.also_supporting_bills do |tp|
      @opposing_suggestions[1][:my_bills_supported_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.also_opposing_bills do |tp|
      @opposing_suggestions[1][:my_bills_opposed_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.also_approved_senators do |tp|
      @opposing_suggestions[1][:my_approved_sens_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.also_disapproved_senators do |tp|
      @opposing_suggestions[1][:my_disapproved_sens_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.also_approved_representatives do |tp|
      @opposing_suggestions[1][:my_approved_reps_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

  pt.also_disapproved_representatives do |tp|
      @opposing_suggestions[1][:my_disapproved_reps_facet].each do |p|
        tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
      end
        
  end

end

