module AboutHelper
  def learn_about(subject)
    BlueCloth.new(render(:partial => "#{subject}/learn")).to_html
  end
end
