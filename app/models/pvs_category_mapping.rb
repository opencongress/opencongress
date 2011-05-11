class PvsCategoryMapping < ActiveRecord::Base  
  belongs_to :pvs_category
  belongs_to :pvs_category_mappable, :polymorphic => true
  
  def to_s
    out = pvs_category.name
    mappable = pvs_category_mappable
    
    case mappable
    when Subject
      out += " --> Issue: #{mappable.term}"
    when CrpIndustry
      out += " --> CrpIndustry: #{mappable.name}"
    when CrpSector
      out += " --> CrpSector: #{mappable.name}"
    end
    return out
  end
end
