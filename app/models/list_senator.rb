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

  @@ABBREV_FOR_STATE = { "alabama" => "AL",
    "alaska" => "AK" ,
    "arizona" => "AZ" ,
    "arkansas" => "AR" ,
    "california" => "CA" ,
    "colorado" => "CO" ,
    "connecticut" => "CT" ,
    "delaware" => "DE" ,
    "district of columbia" => "DC" ,
    "florida" => "FL" ,
    "georgia" => "GA" ,
    "hawaii" => "HI" ,
    "idaho" => "ID" ,
    "illinois" => "IL" ,
    "indiana" => "IN" ,
    "iowa" => "IA" ,
    "kansas" => "KS" ,
    "kentucky" => "KY" ,
    "louisiana" => "LA" ,
    "maine" => "ME" ,
    "maryland" => "MD" ,
    "massachusetts" => "MA" ,
    "michigan" => "MI" ,
    "minnesota" => "MN" ,
    "mississippi" => "MS" ,
    "missouri" => "MO" ,
    "montana" => "MT" ,
    "nebraska" => "NE" ,
    "nevada" => "NV" ,
    "new hampshire" => "NH" ,
    "new jersey" => "NJ" ,
    "new mexico" => "NM" ,
    "new york" => "NY" ,
    "north carolina" => "NC" ,
    "north dakota" => "ND" ,
    "ohio" => "OH" ,
    "oklahoma" => "OK" ,
    "oregon" => "OR" ,
    "pennsylvania" => "PA" ,
    "rhode island" => "RI" ,
    "south carolina" => "SC" ,
    "south dakota" => "SD" ,
    "tennessee" => "TN" ,
    "texas" => "TX" ,
    "utah" => "UT" ,
    "vermont" => "VT" ,
    "virginia" => "VA" ,
    "washington" => "WA" ,
    "west virginia" => "WV" ,
    "wisconsin" => "WI" ,
    "wyoming" => "WY" }

  def abbrev_for_state(name)
    @@ABBREV_FOR_STATE[name.downcase]
  end
  
  @@STATE_FOR_ABBREV = { 
    "AL" => "Alabama",
    "AK" => "Alaska" ,
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "AS" => "American Samoa",    
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "DC" => "District of Columbia",
    "FL" => "Florida",
    "GA" => "Georgia",
    "GU" => "Guam",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "PR" => "Puerto Rico",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VI" => "Virgin Islands",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming" }

    @@RESIDENT_FOR_ABBREV = {
    "AL" => "Alabamian", 		  
    "AK" => "Alaskan", 	      
    "AZ" => "Arizonan", 		  
    "AR" => "Arkansan", 		  
    "CA" => "Californian", 	  
    "CO" => "Coloradan",   
    "CT" => "Connecticuter", 	  
    "DE" => "Delawarean", 	      
    "FL" => "Floridian", 		  
    "GA" => "Georgian", 	      
    "HI" => "Hawaiian", 		  
    "ID" => "Idahoan", 	      
    "IL" => "Illinoisan", 	      
    "IN" => "Indianian", 		  
    "IA" => "Iowan", 	          
    "KS" => "Kansan", 	          
    "KY" => "Kentuckian", 	      
    "LA" => "Louisianian", 	  
    "ME" => "Mainer", 			  
    "MD" => "Marylander", 	      
    "MA" => "Massachusettsan",   
    "MI" => "Michiganian", 	  
    "MN" => "Minnesotan", 	      
    "MS" => "Mississippian", 	  
    "MO" => "Missourian", 	      
    "MT" => "Montanan", 	      
    "NE" => "Nebraskan", 	      
    "NV" => "Nevadan", 		  
    "NH" => "New Hampshirite",   
    "NJ" => "New Jerseyan",   	  
    "NM" => "New Mexican", 	  
    "NY" => "New Yorker", 	      
    "NC" => "North Carolinian",  
    "ND" => "North Dakotan", 	  
    "OH" => "Ohioan", 	          
    "OK" => "Oklahoman", 		  
    "OR" => "Oregonian", 	      
    "PA" => "Pennsylvanian", 	  
    "RI" => "Rhode Islander", 	  
    "SC" => "South Carolinian",  
    "SD" => "South Dakotan", 	  
    "TN" => "Tennessean", 	      
    "TX" => "Texan", 			  
    "UT" => "Utahn", 			  
    "VT" => "Vermonter", 	      
    "VA" => "Virginian", 	      
    "WA" => "Washingtonian", 	  
    "WV" => "West Virginian", 	  
    "WI" => "Wisconsinite", 	  
    "WY" => "Wyomingite" }     

  def state_for_abbrev(abbr)
    @@STATE_FOR_ABBREV[abbr.upcase]
  end
  
  def resident_for_abbrev(abbr)
    @@RESIDENT_FOR_ABBREV[abbr.upcase]
  end  

  def set_party
     self.party = self.roles.first.party unless self.roles.empty?
  end

  def obj_title
    self.title
  end


end
