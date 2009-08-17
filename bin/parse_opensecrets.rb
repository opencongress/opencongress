#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../config/environment'
end

path = OPENSECRETS_DATA_PATH

contrib = "Mems_TopContrib.txt"
sector = "MemsSector.txt"
total_raised = "MemsTotRaised.txt"

#Cache of objects, so I don't need to fetch so often
peeps = {}
sectors = {}
contribs = {}

Person.transaction {

IO.foreach(path + sector) do |line|
  line.chomp!
  cid =  line[0...9]
  name = line[9...49].sub(/\s+$/, "")
  sector = line[49...84].sub(/\s+$/, "")
  total = line[84...95].to_i
  date = DateTime.parse(line[95..-1])
  p = peeps[cid] || Person.find_by_osid(cid)

  if p.nil?
    puts [cid,name,sector,total].inspect
  else 
    peeps[cid] ||= p
    s = sectors[sector] || Sector.find_or_create_by_name(sector)
    sectors[sector] ||= s
    ps = PersonSector.find_or_create_by_person_id_and_sector_id(p.id, s.id)
    ps.total = total
    ps.revision_date = date
    ps.save
    puts "Added sector: #{name} / #{sector}"
  end

end

IO.foreach(path + contrib) do |line|
  line.chomp!
  cid =  line[0...9]
  name = line[9...49].sub(/\s+$/, "")
  contributor = line[49...89].sub(/\s+$/, "")
  total = line[89...99].to_i
  date = DateTime.parse(line[100..-1])
  p = peeps[cid] || Person.find_by_osid(cid)

  if p.nil?
    puts [cid,name,sector,total].inspect
  else 
    peeps[cid] ||= p
    c = contribs[contributor] || Contributor.find_or_create_by_name(contributor)
    contribs[contributor] ||= c
    p.top_contributor = c
    p.top_contribution = total
    p.top_contributor_at = date
    p.save
    puts "Added contributor: #{name} / #{contributor}"
  end
end

IO.foreach(path + total_raised) do |line|
  line.chomp!
  cid = line[0...9]
  name = line[9...49].sub(/\s+$/, "")
  total_raised = line[49...71].to_i
  begin
    filing_date = DateTime.parse(line[71..-1])
  rescue
    filing_date = DateTime.now
  end
  
  p = peeps[cid] || Person.find_by_osid(cid)
  
  if p.nil?
    puts [cid,name,sector,total_raised].inspect
  else
    peeps[cid] ||= p
    p.money_raised = total_raised
    p.money_raised_at = filing_date
    p.save
    puts "Added total raised: #{name} / #{total_raised}"
  end
  
end

}
