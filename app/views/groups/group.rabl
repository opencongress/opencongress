
attributes :name, :id, :created_at, :updated_at, :pvs_category_id, :district_id, :group_image_file_name, :group_image_content_type, :description, :state_id, :invite_type

code(:permalink) { |g| group_path(g) }
code(:member_count) { |g| group_members_num(g) }
