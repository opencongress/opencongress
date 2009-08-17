class ScrapeToolsController < ApplicationController

  require 'hpricot'
  require 'open-uri'
  require 'timeout'
  
  def get_url_title
    title = ""
    unless params[:url].blank?
      url = params[:url]
      regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/    
      if url =~ regex
        begin
          Timeout::timeout(3) {
            doc = Hpricot(open(url))
            title = (doc/"title").inner_html
          }
        rescue Timeout::Error
          title = ""
        end
      end
    end
    render :text => title
  end

  def get_youtube_embed
    embed = ""
    unless params[:url].blank?
      url = params[:url]
      regex = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/    
      if url =~ regex
        doc = Hpricot(open(url))
        doc.at("input#embed_code")['value']
        embed = CGI::unescapeHTML(doc.at("input#embed_code")['value'])
      end
    end
    render :text => embed
  end
end
