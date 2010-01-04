class ScrapeToolsController < ApplicationController
  require 'hpricot'
  require 'open-uri'
  require 'timeout'
  
  def get_url_title
    title = ""
    unless params[:url].blank?
      if doc = get_xml_url(params[:url])
        title = (doc/"title").inner_html
      end
    end
    render :text => title
  end

  def get_youtube_embed
    embed = ""
    unless params[:url].blank?
      if doc = get_xml_url(params[:url])
        doc.at("input#embed_code")['value']
        embed = CGI::unescapeHTML(doc.at("input#embed_code")['value'])
      end
    end
    render :text => embed
  end

  private

  def get_xml_url(u)
    regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/    
    if u =~ regex
      begin
        Timeout::timeout(3) {
          Hpricot(open(u))
        }
      rescue Timeout::Error
        nil
      end
    end
  end

end