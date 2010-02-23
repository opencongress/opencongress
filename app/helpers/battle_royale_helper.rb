module BattleRoyaleHelper

	def bill_status_table(bill = @bill)
		status_hash = bill.bill_status_hash
		text = %Q{<div class="bill-status-box"><table border="0" cellpadding="0" cellspacing="0" id="bill-status">}
		i = 0
		text += "<tr>"
		status_hash['steps'].each do |s|
			#if s.has_value?('Introduced')
			# i += 1
			#else
			if i != 0
				text += %Q{<td rowspan="2" class="divide"><img src="/images/#{s['result']}.gif" alt="result"></td>}
			end
			text += %Q{<td class="#{s['class']}">#{s['text']}</td>}
			i += 1
		end
		text += "</tr><tr>"
		i = 0
		status_hash['steps'].each do |s|
			text += s['date'] ? %Q{<td class="#{s['class']}">#{s['date'].strftime('%B %d, %Y')}</td>} : %Q{<td class="#{s['class']}"></td>}
			i += 1
		end    
    text += "</tr></table></div>"
  end
	
	def th_sort(th_text, th_sort, th_order) 
		th_class = ""
		if params[:sort] == th_sort && params[:order] == th_order 
			if th_order == "asc"
				th_class = "up"
				th_order = "desc"
			else
				th_class = "down"
				th_order = "asc"
			end
		end
		link_to th_text, params.merge({:sort => th_sort, :order => th_order, :page => 1}), :class => th_class
	end
end
