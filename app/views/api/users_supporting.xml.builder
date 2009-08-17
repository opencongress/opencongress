xml.instruct! :xml, :version=>"1.0" 
 
xml.opencongress_users_tracking do |pt|
  
  pt << @object.to_light_xml(:skip_instruct => true)
  pt.users_supporting(@supporting_suggestions[0])
  pt.also_supporting_bills do |tp|
      if @supporting_suggestions[1][:my_bills_supported_facet]
        @supporting_suggestions[1][:my_bills_supported_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end
        
  end

  pt.also_opposing_bills do |tp|
      if @supporting_suggestions[1][:my_bills_opposed_facet]
        @supporting_suggestions[1][:my_bills_opposed_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end 
  end

  pt.also_approved_senators do |tp|
      if @supporting_suggestions[1][:my_approved_sens_facet]
        @supporting_suggestions[1][:my_approved_sens_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end      
  end

  pt.also_disapproved_senators do |tp|
      if @supporting_suggestions[1][:my_disapproved_sens_facet]
        @supporting_suggestions[1][:my_disapproved_sens_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end        
  end

  pt.also_approved_representatives do |tp|
      if @supporting_suggestions[1][:my_approved_reps_facet]
        @supporting_suggestions[1][:my_approved_reps_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end        
  end

  pt.also_disapproved_representatives do |tp|
      if @supporting_suggestions[1][:my_disapproved_reps_facet]
        @supporting_suggestions[1][:my_disapproved_reps_facet].each do |p|
          tp << p[:object].to_light_xml(:skip_instruct => true, :skip_types => false)
        end
      end        
  end

end

