module Admin::StatsHelper
  def bgcolor_for_commentary_date(d)
    if (Time.now.to_i - d.to_i > 5.days.to_i)
      return 'red'
    elsif (Time.now.to_i - d.to_i > 2.days.to_i)
      return 'yellow'
    else
      return 'green'
    end
  end
  
  def bgcolor_for_govtrack_date(d)
    if (Time.now.to_i - d.to_i > 5.days.to_i)
      return 'yellow'
    else
      return 'green'
    end
  end
  
  def bgcolor_for_roll_call_date(gt, oc)
    if (gt.to_time - oc >= 2.days.to_i)
      return 'red'
    elsif (gt.to_time - oc >= 1.days.to_i)
      return 'yellow'
    else
      return 'green'
    end
  end
end

