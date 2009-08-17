module CommitteeHelper
  def link_to_report(report)
    link_to report.title.capitalize, :action => :report, :id => report
  end
end
