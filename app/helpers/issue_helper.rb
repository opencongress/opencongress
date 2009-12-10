module IssueHelper

  def link_to_subjects(subjects)
    subjects.map { |s| link_to s.term, :action => 'show', :id => s }.to_sentence
  end

  def link_to_ordering(name, action, order)
    out = ""
    out += "<strong>" if assigns["order"] == order
    out += link_to name, :action => action
    out += "</strong>" if assigns["order"] == order
    return out
  end

  def link_to_letter(letter)
    link_to letter, :action => 'alphabetical', :id => letter
  end

end
