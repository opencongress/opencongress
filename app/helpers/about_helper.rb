module AboutHelper
  def learn_about(subject)
    require 'bluecloth'
    BlueCloth.new(render(:partial => "#{subject}/learn")).to_html
  end
end
