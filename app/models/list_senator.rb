class ListSenator < ActiveRecord::Base

  def to_param
    unless unaccented_name.nil?
      "#{id}_#{unaccented_name.downcase.gsub(/[^a-z]+/i, '_').gsub(/\s/, '_')}"
    else
      "#{id}"
    end
  end

  def ident
    "#{id}_#{firstname.downcase}_#{lastname.downcase}"
  end

  def belongs_to_major_party?
    ((party == 'Democrat') || (party == 'Republican'))
  end
  
  def party_and_state
    "#{self.party[0,1]}-#{self.state}"
  end
  
  def opposing_party
    if belongs_to_major_party?
      if party == 'Democrat'
        return 'Republican'
      else
        return 'Democrat'
      end
    else
      "N/A"
    end
  end
  def select_list_name
    "#{lastname}, #{firstname} " + party_and_state
  end
  def short_name
    "#{title} " + lastname
  end
  def full_name
    "#{firstname} #{lastname}"
  end
  def title_full_name
		"#{title} " + full_name
	end
	
	def title_long
	  case self.title
	    when 'Sen.'
	      'Senator'
	    when 'Rep.'
	      'Representative'
	  end
	end
	
	def title_full_name_party_state
	  title_full_name + " " + party_and_state
	end
  def popular_name
    "#{sunlight_nickname || nickname || firstname} #{lastname}"
  end

  def set_party
     self.party = self.roles.first.party unless self.roles.empty?
  end

  def obj_title
    self.title
  end


end
