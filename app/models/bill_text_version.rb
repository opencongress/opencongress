class BillTextVersion < ActiveRecord::Base
  belongs_to :bill
  has_many :bill_text_nodes, :dependent => :destroy, :order => 'nid'
  
  @@VERSION_NAMES = {
    'ih' => 'Introduced in House',
    'ihr' => 'Introduced in House-Reprint',
    'ih_s' => 'Introduced in House (No.) Star Print',
    'rih' => 'Referral Instructions House',
    'rfh' => 'Referred in House',
    'rfhr' => 'Referred in House-Reprint',
    'rfh_s' => 'Referred in House (No.) Star Print',
    'rth' => 'Referred to Committee House',
    'rah' => 'Referred w/Amendments House',
    'rch' => 'Reference Change House',
    'rh' => 'Reported in House',
    'rhr' => 'Reported in House-Reprint',
    'rh_s' => 'Reported in House (No.) Star Print',
    'rdh' => 'Received in House',
    'ash' => 'Additional Sponsors House',
    'c' => 'Sponsor Change House',
    'cdh' => 'Committee Discharged House',
    'hdh' => 'Held at Desk House',
    'iph' => 'Indefinitely Postponed in House',
    'lth' => 'Laid on Table in House',
    'oph' => 'Ordered to be Printed House',
    'pch' => 'Placed on Calendar House',
    'fah' => 'Failed Amendment House',
    'ath' => 'Agreed to House',
    'cph' => 'Considered and Passed House',
    'eh' => 'Engrossed in House',
    'ehr' => 'Engrossed in House-Reprint',
    'eh_s' => 'Engrossed in House (No.) Star Print [*]',
    'eah' => 'Engrossed Amendment House',
    'reah' => 'Re-engrossed Amendment House',
    'is' => 'Introduced in Senate',
    'isr' => 'Introduced in Senate-Reprint',
    'is_s' => 'Introduced in Senate (No.) Star Print',
    'ris' => 'Referral Instructions Senate',
    'rfs' => 'Referred in Senate',
    'rfsr' => 'Referred in Senate-Reprint',
    'rfs_s' => 'Referred in Senate (No.) Star Print',
    'rts' => 'Referred to Committee Senate',
    'ras' => 'Referred w/Amendments Senate',
    'rcs' => 'Reference Change Senate',
    'rs' => 'Reported in Senate',
    'rsr' => 'Reported in Senate-Reprint',
    'rs_s' => 'Reported in Senate (No.) Star Print',
    'rds' => 'Received in Senate',
    'sas' => 'Additional Sponsors Senate',
    'cds' => 'Committee Discharged Senate',
    'hds' => 'Held at Desk Senate',
    'ips' => 'Indefinitely Postponed in Senate',
    'lts' => 'Laid on Table in Senate',
    'ops' => 'Ordered to be Printed Senate',
    'pcs' => 'Placed on Calendar Senate',
    'ats' => 'Agreed to Senate',
    'cps' => 'Considered and Passed Senate',
    'fps' => 'Failed Passage Senate',
    'es' => 'Engrossed in Senate',
    'esr' => 'Engrossed in Senate-Reprint',
    'es_s' => 'Engrossed in Senate (No.) Star Print',
    'eas' => 'Engrossed Amendment Senate',
    'res' => 'Re-engrossed Amendment Senate',
    're' => 'Reprint of an Amendment',
    's_p' => 'Star (No.) Print of an Amendment',
    'pp' => 'Public Print',
    'enr' => 'Enrolled Bill',
    'renr' => 'Re-enrolled',
    'as' => 'Amendment in Senate',
    'as2' => 'Amendment in Senate (2)',
    'ocun' => 'OpenCongress Prepared (Unofficial)',
    'ocas' => 'Amendment in Senate (OC Prepared)'
  }
  
  def pages
    (word_count / 170).ceil
  end
  
  def pretty_version
    @@VERSION_NAMES[self.version]
  end
  
  def top_comment_nodes(limit = 3)
    BillTextNode.find_by_sql(["SELECT bill_text_nodes.id, bill_text_nodes.nid, bill_text_nodes.bill_text_version_id, count(comments.id) as comment_count
                  FROM bill_text_nodes INNER JOIN comments ON bill_text_nodes.id=comments.commentable_id 
                  WHERE bill_text_nodes.bill_text_version_id=? AND comments.commentable_type='BillTextNode' 
                  GROUP BY bill_text_nodes.id, bill_text_nodes.nid, bill_text_nodes.bill_text_version_id ORDER BY count(comments.id) DESC LIMIT ?;", self.id, limit])
  end
  
end