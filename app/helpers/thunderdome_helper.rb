module ThunderdomeHelper

	def bill_title_vertical(this_bill)
		letters = ''
		bill = this_bill.title_typenumber_only.gsub!(/[\.\s]*/, "")
		bill = bill.split(//)
		bill.each do |ltr|
		 	letters += "#{ltr}<br />"
		end
		letters
	end
	

end
