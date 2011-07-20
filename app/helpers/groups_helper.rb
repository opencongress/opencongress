module GroupsHelper
  def group_image(group)
    group.group_image_file_name.blank? ? image_tag('promo.gif') : image_tag(group.group_image.url(:thumb))
  end
  
  def group_header_class(sort_target, sort_type)
    if sort_type =~ /^#{sort_target}/i
      return (sort_type =~ /desc/i) ? 'down' : 'up'
    end
    
    return ''
  end
  
  def group_members_num(group)
    num = !group.has_attribute?(:group_members_count) ? group.active_members.count + 1 : group.group_members_count.to_i + 1
    number_with_delimiter(num)
  end
  
  def show_search?
    @state.nil?
  end
end

