#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
require 'net/http'
require 'fileutils'

Settings.base_url = "www.senate.gov"

PAGES = {
"senate aging (special)" => "/general/committee_membership/committee_memberships_SPAG.htm",
"senate agriculture, nutrition, and forestry" => "/general/committee_membership/committee_memberships_SSAF.htm",
"senate appropriations" => "/general/committee_membership/committee_memberships_SSAP.htm",
"senate armed services" => "/general/committee_membership/committee_memberships_SSAS.htm",
"senate banking, housing, and urban affairs" => "/general/committee_membership/committee_memberships_SSBK.htm",
"senate budget" => "/general/committee_membership/committee_memberships_SSBU.htm",
"senate commerce, science, and transportation" => "/general/committee_membership/committee_memberships_SSCM.htm",
"senate commission on security and cooperation in europe" => "/general/committee_membership/committee_memberships_JCSE.htm",
"senate energy and natural resources" => "/general/committee_membership/committee_memberships_SSEG.htm",
"senate environment and public works" => "/general/committee_membership/committee_memberships_SSEV.htm",
"senate finance" => "/general/committee_membership/committee_memberships_SSFI.htm",
"senate foreign relations" => "/general/committee_membership/committee_memberships_SSFR.htm",
"senate health, education,  labor, and pensions" => "/general/committee_membership/committee_memberships_SSHR.htm",
"senate homeland security and governmental affairs" => "/general/committee_membership/committee_memberships_SSGA.htm",
"senate indian affairs" => "/general/committee_membership/committee_memberships_SLIA.htm",
"senate joint economic committee" => "/general/committee_membership/committee_memberships_JSEC.htm",
"senate joint printing" => "/general/committee_membership/committee_memberships_JSPR.htm",
"senate joint taxation" => "/general/committee_membership/committee_memberships_JSTX.htm",
"senate joint the library" => "/general/committee_membership/committee_memberships_JSLC.htm",
"senate judiciary" => "/general/committee_membership/committee_memberships_SSJU.htm",
"senate rules and administration" => "/general/committee_membership/committee_memberships_SSRA.htm",
"senate select ethics" => "/general/committee_membership/committee_memberships_SLET.htm",
"senate intelligence (select)" => "/general/committee_membership/committee_memberships_SLIN.htm",
"senate small business and entrepreneurship" => "/general/committee_membership/committee_memberships_SSSB.htm",
"senate united states senate caucus on international narcotics control" => "/general/committee_membership/committee_memberships_SCNC.htm",
"senate veterans' affairs" => "/general/committee_membership/committee_memberships_SSVA.htm"
}

unless File.exist? File.dirname(__FILE__) + "/committee_pages"
  FileUtils.mkdir File.dirname(__FILE__) + "/committee_pages"
end

comms = Committee.major_committees.select { |c| c.name.match /senate/i }.sort_by { |v| [v.name, v.subcommittee_name] }

files = []

#make sure i have stuff for all senate committees.
comms.each do |comm| 
  path = PAGES[comm.name.downcase]
  filename = path.split(/\//).last
  files.push filename
  outfile = File.dirname(__FILE__) + "/committee_pages/#{filename}"
  if path.nil? 
    raise "can't find page for committee: #{comm.name.downcase}" 
  end
  unless File.exist? outfile
    File.open(outfile, "w") do |f|
      f.print Net::HTTP.get(Settings.base_url, path)
    end
  end
end

comms.each do |c|
  
end
