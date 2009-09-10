class VotingSimilaritiesFunctions < ActiveRecord::Migration
  def self.up
    #execute  "CREATE FUNCTION plpgsql_call_handler()
     #        RETURNS OPAQUE AS '/opt/local/postgresql819/lib/plpgsql.so' LANGUAGE 'C'"
    #execute  "CREATE LANGUAGE 'plpgsql' HANDLER plpgsql_call_handler LANCOMPILER 'PL/pgSQL'"
    execute "CREATE OR REPLACE FUNCTION plpgsql_call_handler()
      RETURNS language_handler AS
    '$libdir/plpgsql', 'plpgsql_call_handler'
      LANGUAGE 'c'"         
    execute "CREATE LANGUAGE 'plpgsql' HANDLER plpgsql_call_handler;"
    
    execute  "CREATE FUNCTION oc_votes_together(pid integer, after timestamp) RETURNS setof record  AS $$
              DECLARE
                a_vote RECORD;
                b_vote RECORD;
                insert_statement TEXT;
                ordered_grouped_select TEXT;
              BEGIN
                EXECUTE 'CREATE TEMPORARY TABLE t_votes (LIKE roll_call_votes) ON COMMIT DROP';

              FOR a_vote IN SELECT rcv.* FROM roll_call_votes rcv, roll_calls rc WHERE rc.date > after AND rc.id=rcv.roll_call_id AND rcv.person_id=pid AND rcv.vote != '0' AND rcv.vote != 'P' LOOP
                insert_statement := 'INSERT INTO t_votes SELECT * FROM roll_call_votes WHERE roll_call_id='||a_vote.roll_call_id||' AND person_id != '||pid||' AND vote='||quote_literal(a_vote.vote);
                EXECUTE insert_statement;
              END LOOP;

              ordered_grouped_select := 'SELECT person_id, count(person_id) as v_count FROM t_votes GROUP BY person_id ORDER BY v_count DESC';
              FOR b_vote IN EXECUTE ordered_grouped_select LOOP
                RETURN NEXT b_vote;
              END LOOP;

              EXECUTE 'DROP TABLE t_votes';
            END;
            $$ LANGUAGE plpgsql;"
            
    execute  "CREATE FUNCTION oc_votes_apart(pid integer, after timestamp) RETURNS setof record  AS $$
              DECLARE
                  a_vote RECORD;
                  b_vote RECORD;
                  insert_statement TEXT;
                  ordered_grouped_select TEXT;
              BEGIN
                EXECUTE 'CREATE TEMPORARY TABLE t_votes (LIKE roll_call_votes) ON COMMIT DROP';

                FOR a_vote IN SELECT rcv.* FROM roll_call_votes rcv, roll_calls rc WHERE rc.date > after AND rc.id=rcv.roll_call_id AND rcv.person_id=pid AND rcv.vote != '0' AND rcv.vote != 'P' LOOP
                  insert_statement := 'INSERT INTO t_votes SELECT * FROM roll_call_votes WHERE roll_call_id='||a_vote.roll_call_id||' AND person_id != '||pid||' AND vote IS NOT NULL AND vote !='||quote_literal('0')||' AND vote !='||quote_literal('P')||' AND vote !='||quote_literal(a_vote.vote);
                  EXECUTE insert_statement;
                END LOOP;

                ordered_grouped_select := 'SELECT person_id, count(person_id) as v_count FROM t_votes GROUP BY person_id ORDER BY v_count DESC';
                FOR b_vote IN EXECUTE ordered_grouped_select LOOP
                  RETURN NEXT b_vote;
                END LOOP;

                EXECUTE 'DROP TABLE t_votes';
              END;
              $$ LANGUAGE plpgsql;"
  end
  
  def self.down
    execute "DROP FUNCTION oc_votes_together(pid integer, after timestamp);"
    execute "DROP FUNCTION oc_votes_apart(pid integer, after timestamp);"
  end
end