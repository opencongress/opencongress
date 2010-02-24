module FacebookHelper
  def billsearch_spinner
    %Q{<div id="billedit_search_spinner" style="display: none; margin-top: 7px;">#{image_tag 'spinner_pie.gif'} Searching...</div>}
  end
  
  def editbill_spinner
    %Q{<div id="billedit_edit_spinner" style="display: none; margin-top: 7px;">#{image_tag 'spinner_pie.gif'} Updating...</div>}
  end
end
