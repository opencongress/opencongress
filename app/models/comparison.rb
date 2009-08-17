class Comparison < ActiveRecord::Base
  has_many :comparison_data_points, :order => "id ASC"
  
  def self.latest(chamber)
    self.find_by_chamber(chamber, :order => "created_at DESC")
  end
  
  def graph_link(placemark = nil)
    if placemark
      "http://chart.apis.google.com/chart?chds=0,#{self.comparison_data_points.maximum(:comp_value)}&cht=lc&chs=200x100&chm=V,6FC6B0,0,#{placemark}.0,2.0&chd=t:#{self.comparison_data_points.collect{|p| p.comp_value}.join(',')}&chxl=0:|0|10|20|30|40|50|60|70|80|90|100&chxt=x"
    else
      "http://chart.apis.google.com/chart?cht=lc&chs=200x125&chd=t:#{self.comparison_data_points.collect{|p| p.comp_value}.join(',')}&chxl=0:|0|10|20|30|40|50|60|70|80|90|100&chxt=x"
    end      
  end
  
  def self.run_senate
    a = 0
    prim_hash = Hash.new
    Person.senators.each do |s1|
      Person.senators.each do |s2|
        unless s1 == s2
          unless prim_hash["#{s1.id}:#{s2.id}"] || prim_hash["#{s2.id}:#{s1.id}"]
            a += 1
            vt = RollCall.vote_together(s1,s2)
            prim_hash["#{s1.id}:#{s2.id}"] = ((vt[0].to_f / vt[1].to_f) * 100.0).round
          end
        end
      end
    end

    total = 0
    prim_hash.each do |key,value|
      total += value
    end

    average = total / prim_hash.length if prim_hash.length > 0

    repubs = Person.sen.republican.collect {|p| p.id}
    democs = Person.sen.democrat.collect {|p| p.id}

    total_republican_democrat = 0
    total_republican_democrat_arr = []
    r_d_combos = 0

    total_democrat_democrat = 0
    total_democrat_democrat_arr = []
    d_d_combos = 0

    total_republican_republican = 0
    total_republican_republican_arr = []
    r_r_combos = 0
    
    prim_hash.each do |key,value|
      (p1,p2) = key.split(':')
      if ( repubs.include?(p1.to_i) && democs.include?(p2.to_i) ) || ( repubs.include?(p2.to_i) && democs.include?(p1.to_i) )
        total_republican_democrat += value
        total_republican_democrat_arr << value
        r_d_combos += 1
      elsif ( democs.include?(p2.to_i) && democs.include?(p1.to_i) )
        total_democrat_democrat += value
        total_democrat_democrat_arr << value
        d_d_combos += 1
      elsif ( repubs.include?(p1.to_i) && repubs.include?(p2.to_i) )      
        total_republican_republican += value
        total_republican_republican_arr << value
        r_r_combos += 1
      end  
    end

    r_d_average = total_republican_democrat / r_d_combos if r_d_combos > 0
    d_d_average = total_democrat_democrat / d_d_combos if d_d_combos > 0
    r_r_average = total_republican_republican / r_r_combos if r_r_combos > 0

    big_t_r_d_h = []
    (0..100).each do |t|
      big_t_r_d_h[t] = total_republican_democrat_arr.select{|p| p == t}.length
    end
    
    c = RepDemComparison.create({:chamber => "senate", :average_value => r_d_average})
    big_t_r_d_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_r_d_h[index]})
    end

    big_t_d_d_h = []
    (0..100).each do |t|
      big_t_d_d_h[t] = total_democrat_democrat_arr.select{|p| p == t}.length
    end
    
    c = DemDemComparison.create({:chamber => "senate", :average_value => d_d_average})
    big_t_d_d_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_d_d_h[index]})
    end

    big_t_r_r_h = []
    (0..100).each do |t|
      big_t_r_r_h[t] = total_republican_republican_arr.select{|p| p == t}.length
    end
    
    c = RepRepComparison.create({:chamber => "senate", :average_value => r_r_average})
    big_t_r_r_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_r_r_h[index]})
    end
   
  end

  def self.run_house
    a = 0
    perc = 0.0
    prim_hash = Hash.new
    rcount = Person.rep.count
    ftime = Time.now
    Person.representatives.each do |s1|
      Person.representatives.each do |s2|
        unless s1 == s2
          unless prim_hash["#{s1.id}:#{s2.id}"] || prim_hash["#{s2.id}:#{s1.id}"]
            a += 1
            if a % (rcount * ( rcount - 1) / 2 / 100) == 0
              perc = perc += 1
              gtime = (Time.now - ftime) / 60 * (100 - perc)
              ftime = Time.now
              puts "#{perc}% done - #{gtime} minutes remaining"
            end
            vt = RollCall.vote_together(s1,s2)
            unless vt[1].nil? || vt[1] < 1
              begin
                prim_hash["#{s1.id}:#{s2.id}"] = ((vt[0].to_f / vt[1].to_f) * 100.0).round
              rescue
                puts "problem"
                prim_hash["#{s1.id}:#{s2.id}"] = 0
              end
            else
              puts "problem2"          
              prim_hash["#{s1.id}:#{s2.id}"] = 0
            end
          end
        end
      end
    end

    total = 0
    prim_hash.each do |key,value|
      total += value
    end

    average = total / prim_hash.length if prim_hash.length > 0

    repubs = Person.rep.republican.collect {|p| p.id}
    democs = Person.rep.democrat.collect {|p| p.id}

    total_republican_democrat = 0
    total_republican_democrat_arr = []
    r_d_combos = 0

    total_democrat_democrat = 0
    total_democrat_democrat_arr = []
    d_d_combos = 0

    total_republican_republican = 0
    total_republican_republican_arr = []
    r_r_combos = 0
    
    prim_hash.each do |key,value|
      (p1,p2) = key.split(':')
      if ( repubs.include?(p1.to_i) && democs.include?(p2.to_i) ) || ( repubs.include?(p2.to_i) && democs.include?(p1.to_i) )
        total_republican_democrat += value
        total_republican_democrat_arr << value
        r_d_combos += 1
      elsif ( democs.include?(p2.to_i) && democs.include?(p1.to_i) )
        total_democrat_democrat += value
        total_democrat_democrat_arr << value
        d_d_combos += 1
      elsif ( repubs.include?(p1.to_i) && repubs.include?(p2.to_i) )      
        total_republican_republican += value
        total_republican_republican_arr << value
        r_r_combos += 1
      end  
    end

    r_d_average = total_republican_democrat / r_d_combos if r_d_combos > 0
    d_d_average = total_democrat_democrat / d_d_combos if d_d_combos > 0
    r_r_average = total_republican_republican / r_r_combos if r_r_combos > 0

    big_t_r_d_h = []
    (0..100).each do |t|
      big_t_r_d_h[t] = total_republican_democrat_arr.select{|p| p == t}.length
    end
    
    c = RepDemComparison.create({:chamber => "house", :average_value => r_d_average})
    big_t_r_d_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_r_d_h[index]})
    end

    big_t_d_d_h = []
    (0..100).each do |t|
      big_t_d_d_h[t] = total_democrat_democrat_arr.select{|p| p == t}.length
    end
    
    c = DemDemComparison.create({:chamber => "house", :average_value => d_d_average})
    big_t_d_d_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_d_d_h[index]})
    end

    big_t_r_r_h = []
    (0..100).each do |t|
      big_t_r_r_h[t] = total_republican_republican_arr.select{|p| p == t}.length
    end
    
    c = RepRepComparison.create({:chamber => "house", :average_value => r_r_average})
    big_t_r_r_h.each_index do |index|
      c.comparison_data_points.create({:comp_indx => index, :comp_value => big_t_r_r_h[index]})
    end
   
  end



  
end
