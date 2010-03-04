class WikiBill

  require 'hpricot'
  require 'open-uri'
  require 'timeout'

  attr_accessor :summary

  def initialize(url)
    puts url
    @url = url
    begin
      doc = nil
      Timeout::timeout(3) {
        doc = Hpricot(open(url))
      }
      unless doc.blank?
        summary_content = (doc/"#Article_summary") 
        summary_content.search("sup").remove
        unless summary_content.blank?
           @summary = summary_content.inner_html
        else
           @summary = nil
        end
      else
        @summary = nil
      end
    rescue Timeout::Error
      @summary = nil
    end 
  end

end
