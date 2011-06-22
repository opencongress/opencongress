module GroupsHelper
  def group_image(group)
    group.group_image_file_name.blank? ? image_tag('promo.gif') : image_tag(group.group_image.url(:thumb))
  end
end

