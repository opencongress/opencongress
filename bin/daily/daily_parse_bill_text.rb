#!/usr/bin/env ruby

if __FILE__ == $0
  require File.dirname(__FILE__) + '/../../config/environment'
else
  puts "Running from #{$0}"
end

require 'rexml/document'
require 'ostruct'
require 'date'
require 'yaml'

include REXML

PATH = Settings.govtrack_data_path + "/#{Settings.default_congress}/bills"

$node_order = 0

class NoUpdateException < StandardError
end

def tree_walk(element, version, in_inline = false, in_removed = false)
  removed = false

  unless element.has_elements?
    if element.name == 'p' and element.text.blank?
      element.parent.delete(element)
    end
  end

  element.elements.to_a.each do |e|
    case e.name
    when 'changed'
       e.name = 'span'
       e.attributes['class'] = 'bill_text_changed'
    when 'changed-from'
       e.name = 'span'
       e.attributes['class'] = 'bill_text_changed_from'
       e.attributes['style'] = 'display: none;'
    when 'changed-to'
       e.name = 'span'
       e.attributes['class'] = 'bill_text_changed_to'
    when 'inserted'
      e.attributes['class'] = "bill_text_inserted"

      e.name = in_inline ? 'span' : 'div'
    when 'removed'
      e.attributes['class'] = "bill_text_removed"
      e.attributes['style'] = "display: none;"
      removed = true

      e.name = in_inline ? 'span' : 'div'
    when 'p'
      #e.name = 'span' if in_inline
    when 'ul'
      e.name = 'span' if in_inline
    when 'h2','h3','h4'
      if in_inline
        e.name = 'span'
        e.attributes['style'] = "font-size: 14px; font-weight:bold;"
      end
    end

    unless e.attributes['nid'].nil? or e.name == 'h2' or e.name == 'h3' or e.name == 'h4' or in_removed
      e.attributes['class'] = 'bill_text_section'
      e.attributes['id'] = "bill_text_section_#{e.attributes['nid']}"
      e.attributes['onmouseover'] = "BillText.mouseOverSection('#{e.attributes['nid']}');" 
      e.attributes['onmouseout'] = "BillText.mouseOutSection('#{e.attributes['nid']}');"

      menu = Element.new "span"
      menu.attributes['class'] = 'bill_text_section_menu'
      menu.attributes['id'] = "bill_text_section_menu_#{e.attributes['nid']}"
      menu.attributes['style'] = 'display:none;'

      comments_show = Element.new "a"
      comments_show.attributes['href'] = "#"
      comments_show.attributes['id'] = "show_comments_link_#{e.attributes['nid']}"
      comments_show.attributes['class'] = "small_button pushright"
      comments_show.attributes['onClick'] = "BillText.showComments(#{version.id}, '#{e.attributes['nid']}'); return false;"
      comments_show.text = ""

      comments_show_span = Element.new "span"
      comments_show_span.text = "Comments"

      comments_show.elements << comments_show_span

      comments_hide = Element.new "a"
      comments_hide.attributes['href'] = "#"
      comments_hide.attributes['id'] = "close_comments_link_#{e.attributes['nid']}"
      comments_hide.attributes['class'] = "small_button pushright"
      comments_hide.attributes['style'] = 'display:none;'
      comments_hide.attributes['onClick'] = "BillText.closeComments(#{version.id}, '#{e.attributes['nid']}'); return false;"
      comments_hide.text = ""

      comments_hide_span = Element.new "span"
      comments_hide_span.text = "Close Comments"

      comments_hide.elements << comments_hide_span

      permalink = Element.new "a"
      permalink.attributes['href'] = "?version=#{version.version}&nid=#{e.attributes['nid']}"
      permalink.attributes['id'] = "permalink_#{e.attributes['nid']}"
      permalink.attributes['class'] = "small_button"
      permalink.text = ""

      permalink_span = Element.new "span"
      permalink_span.text = "Permalink"

      permalink.elements << permalink_span
    
      comments = Element.new "div"
      comments.attributes['id'] = "bill_text_comments_#{e.attributes['nid']}"
      comments.attributes['class'] = 'bill_text_section_comments'
      comments.attributes['style'] = 'display:none;'
      comments.text = ""
      
      comments_clearer = Element.new "br"
      comments_clearer.attributes['class'] = 'clear'
      comments_clearer.text = ""
      
      comments.elements << comments_clearer
      
      img = Element.new "img"
      img.attributes['style'] = 'margin: 5px; text-align: center;'
      img.attributes['src'] = '/images/flat-loader.gif'
      
      comments.elements << img

      menu.elements << comments_show
      menu.elements << comments_hide
      menu.elements << permalink

      e.elements << menu
      e.elements << comments
    end

    tree_walk(e, version, (in_inline or (e.name  =~ /p|em|h2|h3|h4/)), (in_removed or removed))
  end
end

def get_text_word_count(bill_type, bill_number, text_version)
  # get the word count from the text file
  begin
    # try the version first
    text_filename = "#{Settings.govtrack_billtext_path}/#{Settings.default_congress}/#{bill_type}/#{bill_type}#{bill_number}#{text_version}.txt"
    text_file = File.open(text_filename)
  rescue
    begin
      # if that didn't work just use the symlink
      text_filename = "#{Settings.govtrack_billtext_path}/#{Settings.default_congress}/#{bill_type}/#{bill_type}#{bill_number}.txt"
      text_file = File.open(text_filename)
    rescue
      return 0
    end
  end
    
  raw_text = text_file.read
          
  #remove line numbers
  raw_text.gsub!(/^\s*\d+/, "")
  
  word_count = raw_text.scan(/(\w|-)+/).size
  
  raw_text = nil
  text_file.close
  
  return word_count
end

def parse_from_file(bill, text_version, filename)
  file = File.open(filename)
  file_timestamp = File.mtime(filename)
  doc = REXML::Document.new file

  version = bill.bill_text_versions.find_or_create_by_version(text_version)
  if true #version.file_timestamp.nil? or (file_timestamp > version.file_timestamp)        
    puts "Parsing bill text: #{filename}"
    
    version.word_count = get_text_word_count(bill.bill_type, bill.number, text_version)
    
    # now parse the html
    doc_root = doc.root
    
    version.previous_version = doc_root.attributes['previous-status']
    version.difference_size_chars = doc_root.attributes['difference-size-chars']
    version.percent_change = doc_root.attributes['percent-change']
    version.total_changes = doc_root.attributes['total-changes']
    version.file_timestamp = file_timestamp
    version.save
    
    doc_root.name = 'div'
    
    tree_walk(doc_root, version)

    outfile = File.new("#{Settings.oc_billtext_path}/#{Settings.default_congress}/#{bill.bill_type}#{bill.number}#{text_version}.gen.html-oc", "w+")
    doc.write outfile
  else
    puts "Bill text not updated for #{filename}; skipping."
  end
end


begin
  if ENV['PARSE_ONLY'].blank?
    Bill.all_types_ordered.each do |bill_type|
      puts "Parsing bill text of type: #{bill_type}"
      
      type_bills = Bill.find(:all, :conditions => ["bill_type = ? AND session = ?", bill_type, Settings.default_congress])
      type_bills.each_with_index do |bill, i|
        begin
          puts "Parsing bill text: #{bill.typenumber} (#{i+1} of #{type_bills.size})"
    
          # first see if there are multiple versions of the bill
          bill_version_files = Dir.new("#{Settings.govtrack_billtext_diff_path}/#{Settings.default_congress}/#{bill_type}").entries.select { |f| f.match(/#{bill_type}#{bill.number}_(.*)\.xml$/) }
    
          if bill_version_files.size > 0
            puts "Multiple versions exist for #{bill_type}#{bill.number}."
      
            version_hash = {}
            bill_version_files.each do |f| 
              m = /#{bill_type}#{bill.number}_(\w*)-(\w*)\.xml/.match(f)
              version_hash[m.captures[0]] = version_hash[m.captures[0]].nil? ? m.captures[1] : version_hash[m.captures[0]] + m.captures[1]
            end
      
            version_array = version_hash.to_a.sort { |a,b| a[1].size <=> b[1].size }
      
            version = version_array[0][1]
            previous_version = version_array[0][0]
            index = 1
            while index < version_array.size
              version_file = "#{Settings.govtrack_billtext_diff_path}/#{Settings.default_congress}/#{bill_type}/#{bill_type}#{bill.number}_#{previous_version}-#{version}.xml"
        
              parse_from_file(bill, version, version_file)
        
              version = previous_version
              previous_version = version_array[index][0]
        
              index += 1
            end
            version_file = "#{Settings.govtrack_billtext_diff_path}/#{Settings.default_congress}/#{bill_type}/#{bill_type}#{bill.number}_#{previous_version}-#{version}.xml"
            parse_from_file(bill, version, version_file)
      
            # also parse first version from the regular bill text path
            version_file = "#{Settings.govtrack_billtext_path}/#{Settings.default_congress}/#{bill_type}/#{bill_type}#{bill.number}#{version_array.last[0]}.gen.html"
          
            parse_from_file(bill, version_array.last[0], version_file)
          else
            bill_files = Dir.new("#{Settings.govtrack_billtext_path}/#{Settings.default_congress}/#{bill_type}").entries.select { |f| f.match(/#{bill_type}#{bill.number}[a-z]+[0-9]?\.gen\.html$/) }
   
            bill_files.each do |f|
              md = /([hs][jcr]?)(\d+)(\w+)\.gen\.html$/.match(f)
              bill_type, bill_number, text_version = md.captures
     
              parse_from_file(bill, text_version, "#{Settings.govtrack_billtext_path}/#{Settings.default_congress}/#{bill_type}/#{f}")
            end
          end
        rescue
          puts "Couldn't parse bill text for #{bill.typenumber}.  Skipping. The error: #{$!}"
        end
      end
    end
  else
    bill = Bill.find_by_ident(ENV['BILL'])
  
    parse_from_file(bill, ENV['BILL_TEXT_VERSION'], ENV['PARSE_ONLY'])
  end
rescue
  puts "ERROR! Couldn't parse bill text.  Skipping. The error: #{$!}"
end

