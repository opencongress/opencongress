module GossipHelper
  def approve_button(g)
    text = g.approved? ? "unapprove" : "approve"
    submit_tag text
  end

  def frontpage_button(g)
    text = g.frontpage? ? "gossip page" : "front page" 
    submit_tag text
  end

  def title_field(g)
    text_field 'tip', 'title', :value => (g.title || ''), :size => 80, :maxlength => 80
  end

  def tip_field(g)
    text_area 'tip', 'tip', :value => g.tip
  end
end
