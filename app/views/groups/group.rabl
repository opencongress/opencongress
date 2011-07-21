
attributes :name, :id, :to_param, :created_at, :updated_at, :pvs_category_id, :district_id, :description, :state_id, :invite_type

code(:thumbnail_path) { |g| g.group_image.url(:thumb) }
code(:permalink) { |g| group_path(g) }
code(:member_count) { |g| group_members_num(g) }
