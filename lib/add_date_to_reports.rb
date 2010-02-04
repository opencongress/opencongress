class AddDateToReports

  def initalize
  end

  def parse
    require 'rubygems'
    require 'hpricot'
    require 'date'

    dirs = ["house", "senate", "conference", "joint"]

    dirs.each do |a|
      puts "==== DOING #{a} ===="
      log_file = File.open("#{DATA_PATH}/committee_reports/#{a}/log.txt")
      log_file.each do |line|
        parsed_line = line.chomp.split(/\t/)
        file_name = "/#{parsed_line[4][1..-1]}"
        report_name = parsed_line[2]   
        if !report_name.blank?
          report = CommitteeReport.find_by_name(report_name)
          if report
            doc = Hpricot(open(file_name)) rescue nil
            reported_at_arr = doc.search("center").select { |ele| ele.inner_text =~ /ordered to be printed/i }
            reported_at_arr = doc.search("td").select { |ele| ele.inner_text =~ /ordered to be printed/i } if reported_at_arr.empty?
            reported_at_arr = doc.search("p").select { |ele| ele.inner_text =~ /ordered to be printed/i } if reported_at_arr.empty?
            reported_at = nil
            reported_at = Date.parse(reported_at_arr.first.inner_html).to_time unless reported_at_arr.empty? rescue nil
            if reported_at
              if report.created_at.nil? && report.reported_at.nil?
                 report.update_attributes({:reported_at => reported_at, :created_at => reported_at})
              end
              puts "#{report.id} - #{reported_at}"
            end
          end
        end
      end
    end
  end
end
