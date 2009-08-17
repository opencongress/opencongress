class SubjectRelation < ActiveRecord::Base
  belongs_to :subject
  belongs_to :related_subject, :class_name => 'Subject', :foreign_key => :related_subject_id
  
  #This is a little tricky, because it represents a relationship that
  #ought to be symmetric. 
  def SubjectRelation.related(subject, number)
    srs = SubjectRelation.find(:all, :include => [:subject, :related_subject], :conditions =>["subject_id = ? OR related_subject_id = ? ", subject.id, subject.id], :order => "relation_count desc", :limit => number)
    return SubjectRelation.add_up_related_subjects(subject, srs)
  end

  def SubjectRelation.all_related(subject)
    srs = SubjectRelation.find(:all, :include => [:subject, :related_subject], :conditions =>["subject_id = ? OR related_subject_id = ? ", subject.id, subject.id], :order => "relation_count desc")
    return SubjectRelation.add_up_related_subjects(subject, srs)
  end

  private 
  def SubjectRelation.add_up_related_subjects(subject, srs)
    subjects = []
    srs.each do |sr|
      if sr.subject == subject
        subjects.push sr.related_subject
      else
        subjects.push sr.subject
      end
    end
    return subjects
  end

end
