module ProfileHelper

 def draw_edit_in_place(field, rows = 1) 
     @user == current_user ? editable_content(
        :content => {
          :element => 'span',
          :text => (@user[field] && !@user[field].strip.empty?) ? h(@user[field]) : "[Click to Edit]",
          :options => {
            :id => "user_#{field}",
            :class => 'editable-content'
          }
         },
        :url => {
          :controller => 'profile',
          :action => 'edit_profile',
          :field => field,
          :login => @user.login
         },
        :ajax => {
          :okText => "'SAVE'",
          :highlightcolor => "'#DDDDDD'",
          :highlightendcolor => "'#FFFFFF'",
          :rows => rows,
          :cancelText => "'CANCEL'"
         }
      ) : @user[field] ? h(@user[field]) : "[Click to Edit]"
 end

 def editable_content(options)
   options[:content] = { :element => 'span' }.merge(options[:content])
   options[:url] = {}.merge(options[:url])
   options[:ajax] = { :okText => "'Save'", :cancelText => "'Cancel'"}.merge(options[:ajax] || {})
   script = Array.new
   script << "new Ajax.InPlaceEditor("
   script << "  '#{options[:content][:options][:id]}',"
   script << "  '#{url_for(options[:url])}',"
   script << "  {"
   script << options[:ajax].map{ |key, value| "#{key.to_s}: #{value}" }.join(", ")
   script << "  }"
   script << ")"

   content_tag(
     options[:content][:element],
     options[:content][:text],
     options[:content][:options]
   ) + javascript_tag( script.join("\n") )
 end

	def user_name(pronoun,extras)
		if @user == current_user
			use_name = "#{pronoun}"
		else
 			use_name = @user.login + "#{extras}"
		end
	end
	
	def user_bill_vote_string(bill)
		out = "<td"
		if logged_in?
			bv = current_user.bill_votes.find_by_bill_id(bill.id)
      if bv
        if bv.support == 0
				out += " class='color10'>Aye"
      	elsif bv.support == 1 
				out += " class='color0'>Nay"
    		end
			else
				out += ">No Vote"
			end
    end
		out += "\n</td>"
		return out.html_safe
	end
	
  def link_to_report(report)
    link_to report.title.capitalize, :action => :report, :id => report
  end

  def show_vote(user,bill)
     vote = user.bill_votes.find_by_bill_id(bill.id)
     if vote.nil?
       "None"
     elsif vote.support == 0
       "Aye"
     elsif vote.support == 1
       "Nay"
     else
       "None"
     end
  end
  def show_person_vote(person,bill)
      out = ""
      roll_calls = RollCall.find_all_by_bill_id(bill.id)
      unless roll_calls.empty?
        rc_votes = RollCallVote.find_all_by_roll_call_id_and_person_id(roll_calls,person, :include => "roll_call", :order => "roll_calls.date desc", :limit => 1)
        logger.info rc_votes.to_yaml
        unless rc_votes.empty?
          out_ar = []
          rc_votes.each do |rcv|
            out_ar << (rcv.vote == "+" ? "Aye" : ( rcv.vote == "-" ? "Nay" : "Abstain" )) + ' : <span style="font-size:10px;font-style:italics;">' + rcv.roll_call.roll_type + '</span>'
          end
          out << out_ar.join('<br/>')
        end

      end
      if out == ""
        if vote_origin = bill.originating_chamber_vote
            if (vote_origin.where == "h" && person.title == "Rep.") || (vote_origin.where == "s" && person.title == "Sen.")
                if vote_origin.how == "by Unanimous Consent"
                  out << (vote_origin.result == "pass" ? "Aye" : "Nay")
                  out << '<span style="font-size:10px;font-style:italics;"> (unanimous)</span>'
                end
            end
        end
        if vote_other = bill.other_chamber_vote
              if (vote_other.where == "h" && person.title == "Rep.") || (vote_other.where == "s" && person.title == "Sen.")
                if vote_other.how == "by Unanimous Consent"
                  out << (vote_other.result == "pass" ? "Aye" : "Nay")
                  out << '<span style="font-size:10px;font-style:italics;"> (unanimous)</span>'
              end
            end
        end
        if out == ""
          out << "None"
        end
      end
      return out.html_safe
  end
    
end
