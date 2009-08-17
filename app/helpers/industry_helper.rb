module IndustryHelper
  def link_to_sector(sector)
    link_to sector.name, :action => "show", :id => sector
  end

  def industry_recipients_html(person_sectors, top_count)
    return 'No contributions.' unless person_sectors.size > 0
    render :partial => 'person_sector_list', :object => person_sectors,
      :locals => { :top_count => top_count }
  end

  def display_related_bills(person_sectors)
    return "No contributions" unless person_sectors.size > 0
    "<a href='#' id='person_sector_link' onclick='change_vis_text(\"person_sectors\", " +
      "\"person_sector_link\", \"Show contributions\", \"Hide contributions\");return false'>" +
      "Hide contributions</a>"
  end

  def grand_total(person_sectors)
    gt = person_sectors.inject(0) {|sum, ps| sum + ps.total.to_i}
    number_to_currency(gt, :precision => 0)
  end
end
