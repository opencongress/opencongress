class CommentPagesSpeedup < ActiveRecord::Migration
  def self.up
    execute "create or replace function comment_page(comment_id int, c_id int, c_type varchar, comments_per_page int) returns int as $$
    declare
       c_row record;
       rc int := 0;
       found int := 0;
       page_count int := 1;
    begin
       for c_row in select id from comments where commentable_id = c_id and commentable_type = c_type order by comments.root_id ASC, comments.lft ASC loop
          rc := rc + 1;
          if rc = comments_per_page then
             rc := 0;
             page_count := page_count + 1;
          end if;
          if c_row.id = comment_id then
            found := 1;
            exit;
          end if;
       end loop;
       if found = 0 then
         return 1;
       else
         return page_count;
       end if;
    end;
    $$ LANGUAGE plpgsql;"
  end

  def self.down
    execute "drop function comment_page(int, int, varchar, int)"
  end
end
