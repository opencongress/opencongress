--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;


SET search_path = public, pg_catalog;


--
-- Name: aggregate_increment(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION aggregate_increment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    object_type varchar;
                    object_id integer;
                    column_name varchar;
                    agg_date date;
                    
                    entry object_aggregates%ROWTYPE;

                BEGIN
                  IF (TG_TABLE_NAME = 'comments') THEN
                    object_type := NEW.commentable_type;
                    object_id := NEW.commentable_id;
                    column_name := 'comments_count';
                    agg_date := NEW.created_at;
                  ELSIF (TG_TABLE_NAME = 'bookmarks') THEN
                      object_type := NEW.bookmarkable_type;
                      object_id := NEW.bookmarkable_id;
                      column_name := 'bookmarks_count';
                      agg_date := NEW.created_at;
                  ELSIF (TG_TABLE_NAME = 'bill_votes') THEN
                      object_type := 'Bill';
                      object_id := NEW.bill_id;
                      IF (NEW.support = 0) THEN
                        column_name := 'votes_support';
                      ELSE 
                        column_name := 'votes_oppose';
                      END IF;
                      agg_date := NEW.updated_at;
                  ELSIF (TG_TABLE_NAME = 'commentaries') THEN
                      IF (NEW.is_ok = 't') THEN
                        object_type := NEW.commentariable_type;
                        object_id := NEW.commentariable_id;
                        IF (NEW.is_news = 't') THEN
                          column_name := 'news_articles_count';
                        ELSE 
                          column_name := 'blog_articles_count';
                        END IF;
                        agg_date := NEW.date;
                      ELSE
                        RETURN NULL;
                      END IF;
                  END IF;
              
                
                  SELECT * INTO entry FROM object_aggregates WHERE aggregatable_type = object_type AND aggregatable_id = object_id AND date = agg_date::date;
     
                  IF FOUND THEN
                    EXECUTE 'UPDATE object_aggregates SET ' || column_name || ' = ' || column_name || ' + 1 WHERE aggregatable_type = ''' || object_type || ''' AND aggregatable_id = ' || object_id || ' AND date = ''' || agg_date || '''';
                  ELSE
                    EXECUTE 'INSERT INTO object_aggregates (aggregatable_type, aggregatable_id, date, ' || column_name || ') VALUES (''' || object_type || ''', ' ||  object_id || ', ''' || agg_date || ''', 1)';
                  END IF;
                  
                  RETURN NULL;
                END;
            $$;


--
-- Name: comment_page(integer, integer, character varying, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION comment_page(comment_id integer, c_id integer, c_type character varying, comments_per_page integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
    $$;


--
-- Name: oc_votes_apart(integer, timestamp without time zone); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION oc_votes_apart(pid integer, after timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
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
              $$;


--
-- Name: oc_votes_together(integer, timestamp without time zone); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION oc_votes_together(pid integer, after timestamp without time zone) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
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
            $$;


CREATE FUNCTION rank(real[], pg_catalog.tsvector, pg_catalog.tsquery) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rank_wtt$$;


--
-- Name: rank(real[], pg_catalog.tsvector, pg_catalog.tsquery, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank(real[], pg_catalog.tsvector, pg_catalog.tsquery, integer) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rank_wttf$$;


--
-- Name: rank(pg_catalog.tsvector, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank(pg_catalog.tsvector, pg_catalog.tsquery) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rank_tt$$;


--
-- Name: rank(pg_catalog.tsvector, pg_catalog.tsquery, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank(pg_catalog.tsvector, pg_catalog.tsquery, integer) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rank_ttf$$;


--
-- Name: rank_cd(real[], pg_catalog.tsvector, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank_cd(real[], pg_catalog.tsvector, pg_catalog.tsquery) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rankcd_wtt$$;


--
-- Name: rank_cd(real[], pg_catalog.tsvector, pg_catalog.tsquery, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank_cd(real[], pg_catalog.tsvector, pg_catalog.tsquery, integer) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rankcd_wttf$$;


--
-- Name: rank_cd(pg_catalog.tsvector, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank_cd(pg_catalog.tsvector, pg_catalog.tsquery) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rankcd_tt$$;


--
-- Name: rank_cd(pg_catalog.tsvector, pg_catalog.tsquery, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rank_cd(pg_catalog.tsvector, pg_catalog.tsquery, integer) RETURNS real
    LANGUAGE internal IMMUTABLE STRICT
    AS $$ts_rankcd_ttf$$;


--
-- Name: reset_tsearch(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION reset_tsearch() RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_reset_tsearch';


--
-- Name: rewrite(pg_catalog.tsquery, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rewrite(pg_catalog.tsquery, text) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsquery_rewrite_query$$;


--
-- Name: rewrite(pg_catalog.tsquery, pg_catalog.tsquery, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rewrite(pg_catalog.tsquery, pg_catalog.tsquery, pg_catalog.tsquery) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsquery_rewrite$$;


--
-- Name: rewrite_accum(pg_catalog.tsquery, pg_catalog.tsquery[]); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rewrite_accum(pg_catalog.tsquery, pg_catalog.tsquery[]) RETURNS pg_catalog.tsquery
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_rewrite_accum';


--
-- Name: rewrite_finish(pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rewrite_finish(pg_catalog.tsquery) RETURNS pg_catalog.tsquery
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_rewrite_finish';


--
-- Name: set_curcfg(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curcfg(integer) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curcfg';


--
-- Name: set_curcfg(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curcfg(text) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curcfg_byname';


--
-- Name: set_curdict(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curdict(integer) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curdict';


--
-- Name: set_curdict(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curdict(text) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curdict_byname';


--
-- Name: set_curprs(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curprs(integer) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curprs';


--
-- Name: set_curprs(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION set_curprs(text) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_set_curprs_byname';


--
-- Name: setweight(pg_catalog.tsvector, "char"); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION setweight(pg_catalog.tsvector, "char") RETURNS pg_catalog.tsvector
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsvector_setweight$$;


--
-- Name: show_curcfg(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION show_curcfg() RETURNS oid
    LANGUAGE internal STABLE STRICT
    AS $$get_current_ts_config$$;


--
-- Name: snb_en_init(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION snb_en_init(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_snb_en_init';


--
-- Name: snb_lexize(internal, internal, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION snb_lexize(internal, internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_snb_lexize';


--
-- Name: snb_ru_init(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION snb_ru_init(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_snb_ru_init';


--
-- Name: snb_ru_init_koi8(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION snb_ru_init_koi8(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_snb_ru_init_koi8';


--
-- Name: snb_ru_init_utf8(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION snb_ru_init_utf8(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_snb_ru_init_utf8';


--
-- Name: spell_init(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION spell_init(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_spell_init';


--
-- Name: spell_lexize(internal, internal, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION spell_lexize(internal, internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_spell_lexize';


--
-- Name: stat(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION stat(text) RETURNS SETOF statinfo
    LANGUAGE internal STRICT
    AS $$ts_stat1$$;


--
-- Name: stat(text, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION stat(text, text) RETURNS SETOF statinfo
    LANGUAGE internal STRICT
    AS $$ts_stat2$$;


--
-- Name: strip(pg_catalog.tsvector); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION strip(pg_catalog.tsvector) RETURNS pg_catalog.tsvector
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsvector_strip$$;


--
-- Name: syn_init(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION syn_init(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_syn_init';


--
-- Name: syn_lexize(internal, internal, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION syn_lexize(internal, internal, integer) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_syn_lexize';


--
-- Name: thesaurus_init(internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION thesaurus_init(internal) RETURNS internal
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_thesaurus_init';


--
-- Name: thesaurus_lexize(internal, internal, integer, internal); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION thesaurus_lexize(internal, internal, integer, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/tsearch2', 'tsa_thesaurus_lexize';


--
-- Name: to_tsquery(oid, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsquery(oid, text) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$to_tsquery_byid$$;


--
-- Name: to_tsquery(text, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsquery(text, text) RETURNS pg_catalog.tsquery
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/tsearch2', 'tsa_to_tsquery_name';


--
-- Name: to_tsquery(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsquery(text) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$to_tsquery$$;


--
-- Name: to_tsvector(oid, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsvector(oid, text) RETURNS pg_catalog.tsvector
    LANGUAGE internal IMMUTABLE STRICT
    AS $$to_tsvector_byid$$;


--
-- Name: to_tsvector(text, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsvector(text, text) RETURNS pg_catalog.tsvector
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/tsearch2', 'tsa_to_tsvector_name';


--
-- Name: to_tsvector(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION to_tsvector(text) RETURNS pg_catalog.tsvector
    LANGUAGE internal IMMUTABLE STRICT
    AS $$to_tsvector$$;


--
-- Name: token_type(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION token_type(integer) RETURNS SETOF tokentype
    LANGUAGE internal STRICT ROWS 16
    AS $$ts_token_type_byid$$;


--
-- Name: token_type(text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION token_type(text) RETURNS SETOF tokentype
    LANGUAGE internal STRICT ROWS 16
    AS $$ts_token_type_byname$$;


--
-- Name: token_type(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION token_type() RETURNS SETOF tokentype
    LANGUAGE c STRICT ROWS 16
    AS '$libdir/tsearch2', 'tsa_token_type_current';


--
-- Name: tsearch2(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsearch2() RETURNS trigger
    LANGUAGE c
    AS '$libdir/tsearch2', 'tsa_tsearch2';


--
-- Name: tsq_mcontained(pg_catalog.tsquery, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsq_mcontained(pg_catalog.tsquery, pg_catalog.tsquery) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsq_mcontained$$;


--
-- Name: tsq_mcontains(pg_catalog.tsquery, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsq_mcontains(pg_catalog.tsquery, pg_catalog.tsquery) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsq_mcontains$$;


--
-- Name: tsquery_and(pg_catalog.tsquery, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsquery_and(pg_catalog.tsquery, pg_catalog.tsquery) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsquery_and$$;


--
-- Name: tsquery_not(pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsquery_not(pg_catalog.tsquery) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsquery_not$$;


--
-- Name: tsquery_or(pg_catalog.tsquery, pg_catalog.tsquery); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION tsquery_or(pg_catalog.tsquery, pg_catalog.tsquery) RETURNS pg_catalog.tsquery
    LANGUAGE internal IMMUTABLE STRICT
    AS $$tsquery_or$$;


--
-- Name: rewrite(pg_catalog.tsquery[]); Type: AGGREGATE; Schema: public;
--

CREATE AGGREGATE rewrite(pg_catalog.tsquery[]) (
    SFUNC = rewrite_accum,
    STYPE = pg_catalog.tsquery,
    FINALFUNC = rewrite_finish
);


--
-- Name: tsquery_ops; Type: OPERATOR CLASS; Schema: public;
--

CREATE OPERATOR CLASS tsquery_ops
    FOR TYPE pg_catalog.tsquery USING btree AS
    OPERATOR 1 <(pg_catalog.tsquery,pg_catalog.tsquery) ,
    OPERATOR 2 <=(pg_catalog.tsquery,pg_catalog.tsquery) ,
    OPERATOR 3 =(pg_catalog.tsquery,pg_catalog.tsquery) ,
    OPERATOR 4 >=(pg_catalog.tsquery,pg_catalog.tsquery) ,
    OPERATOR 5 >(pg_catalog.tsquery,pg_catalog.tsquery) ,
    FUNCTION 1 tsquery_cmp(pg_catalog.tsquery,pg_catalog.tsquery);


--
-- Name: tsvector_ops; Type: OPERATOR CLASS; Schema: public;
--

CREATE OPERATOR CLASS tsvector_ops
    FOR TYPE pg_catalog.tsvector USING btree AS
    OPERATOR 1 <(pg_catalog.tsvector,pg_catalog.tsvector) ,
    OPERATOR 2 <=(pg_catalog.tsvector,pg_catalog.tsvector) ,
    OPERATOR 3 =(pg_catalog.tsvector,pg_catalog.tsvector) ,
    OPERATOR 4 >=(pg_catalog.tsvector,pg_catalog.tsvector) ,
    OPERATOR 5 >(pg_catalog.tsvector,pg_catalog.tsvector) ,
    FUNCTION 1 tsvector_cmp(pg_catalog.tsvector,pg_catalog.tsvector);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: action_references; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE action_references (
    id integer NOT NULL,
    action_id integer,
    label character varying(255),
    ref character varying(255)
);


--
-- Name: action_references_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE action_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: action_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE action_references_id_seq OWNED BY action_references.id;


--
-- Name: actions; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE actions (
    id integer NOT NULL,
    action_type character varying(255),
    date integer,
    datetime timestamp without time zone,
    how character varying(255),
    "where" character varying(255),
    vote_type character varying(255),
    result character varying(255),
    bill_id integer,
    amendment_id integer,
    type character varying(255),
    text text,
    roll_call_id integer,
    roll_call_number integer,
    created_at timestamp without time zone,
    govtrack_order integer
);


--
-- Name: actions_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE actions_id_seq OWNED BY actions.id;


--
-- Name: amendments; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE amendments (
    id integer NOT NULL,
    number character varying(255),
    retreived_date integer,
    status character varying(255),
    status_date integer,
    status_datetime timestamp without time zone,
    offered_date integer,
    offered_datetime timestamp without time zone,
    bill_id integer,
    purpose text,
    description text,
    updated timestamp without time zone,
    key_vote_category_id integer
);


--
-- Name: amendments_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE amendments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: amendments_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE amendments_id_seq OWNED BY amendments.id;


--
-- Name: api_hits; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE api_hits (
    id integer NOT NULL,
    action character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ip character varying(50)
);


--
-- Name: api_hits_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE api_hits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: api_hits_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE api_hits_id_seq OWNED BY api_hits.id;


--
-- Name: article_images; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE article_images (
    id integer NOT NULL,
    article_id integer,
    image character varying(255)
);


--
-- Name: article_images_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE article_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: article_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE article_images_id_seq OWNED BY article_images.id;


--
-- Name: articles; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE articles (
    id integer NOT NULL,
    title character varying(255),
    article text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    published_flag boolean,
    frontpage boolean DEFAULT false,
    user_id integer,
    render_type character varying(255),
    frontpage_image_url character varying(255),
    excerpt text,
    fti_names tsvector
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE articles_id_seq OWNED BY articles.id;


--
-- Name: bad_commentaries; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bad_commentaries (
    url text,
    commentariable_id integer,
    commentariable_type character varying(255),
    date timestamp without time zone,
    id integer NOT NULL
);


--
-- Name: bad_commentaries_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bad_commentaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bad_commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bad_commentaries_id_seq OWNED BY bad_commentaries.id;


--
-- Name: bill_battles; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_battles (
    id integer NOT NULL,
    first_bill_id integer,
    second_bill_id integer,
    first_score integer,
    second_score integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by integer,
    active boolean,
    run_date timestamp without time zone
);


--
-- Name: bill_battles_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_battles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_battles_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_battles_id_seq OWNED BY bill_battles.id;


--
-- Name: bill_fulltext; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_fulltext (
    bill_id integer,
    fulltext text,
    fti_names tsvector
);


--
-- Name: bill_interest_groups; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_interest_groups (
    id integer NOT NULL,
    bill_id integer NOT NULL,
    crp_interest_group_id integer NOT NULL,
    disposition character varying(255)
);


--
-- Name: bill_interest_groups_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_interest_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_interest_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_interest_groups_id_seq OWNED BY bill_interest_groups.id;


--
-- Name: bill_position_organizations; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_position_organizations (
    id integer NOT NULL,
    bill_id integer NOT NULL,
    maplight_organization_id integer NOT NULL,
    name character varying(255),
    disposition character varying(255),
    citation text
);


--
-- Name: bill_position_organizations_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_position_organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_position_organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_position_organizations_id_seq OWNED BY bill_position_organizations.id;


--
-- Name: bill_referrers; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_referrers (
    id integer NOT NULL,
    bill_id integer,
    url character varying(255),
    created_at timestamp without time zone
);


--
-- Name: bill_referrers_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_referrers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_referrers_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_referrers_id_seq OWNED BY bill_referrers.id;


--
-- Name: bill_stats; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_stats (
    bill_id integer NOT NULL,
    entered_top_viewed timestamp without time zone,
    entered_top_news timestamp without time zone,
    entered_top_blog timestamp without time zone
);


--
-- Name: bill_subjects; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_subjects (
    id integer NOT NULL,
    bill_id integer,
    subject_id integer
);


--
-- Name: bill_subjects_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_subjects_id_seq OWNED BY bill_subjects.id;


--
-- Name: bill_text_nodes; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_text_nodes (
    id integer NOT NULL,
    bill_text_version_id integer,
    nid character varying(255)
);


--
-- Name: bill_text_nodes_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_text_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_text_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_text_nodes_id_seq OWNED BY bill_text_nodes.id;


--
-- Name: bill_text_versions; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_text_versions (
    id integer NOT NULL,
    bill_id integer,
    version character varying(255),
    word_count integer DEFAULT 0,
    previous_version character varying(255),
    difference_size_chars integer DEFAULT 0,
    percent_change integer DEFAULT 0,
    total_changes integer DEFAULT 0,
    file_timestamp timestamp without time zone
);


--
-- Name: bill_text_versions_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_text_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_text_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_text_versions_id_seq OWNED BY bill_text_versions.id;


--
-- Name: bill_titles; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_titles (
    id integer NOT NULL,
    title_type character varying(255),
    "as" character varying(255),
    bill_id integer,
    title text,
    fti_titles tsvector,
    is_default boolean DEFAULT false
);


--
-- Name: bill_titles_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_titles_id_seq OWNED BY bill_titles.id;


--
-- Name: bill_votes; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bill_votes (
    id integer NOT NULL,
    bill_id integer,
    user_id integer,
    support smallint DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bill_votes_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bill_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bill_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bill_votes_id_seq OWNED BY bill_votes.id;


--
-- Name: bills; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bills (
    id integer NOT NULL,
    session integer,
    bill_type character varying(2),
    number integer,
    introduced integer,
    sponsor_id integer,
    lastaction integer,
    rolls character varying(255),
    last_vote_date integer,
    last_vote_where character varying(255),
    last_vote_roll integer,
    last_speech integer,
    pl character varying(255),
    topresident_date integer,
    topresident_datetime date,
    summary text,
    plain_language_summary text,
    hot_bill_category_id integer,
    updated timestamp without time zone,
    page_views_count integer,
    is_frontpage_hot boolean,
    news_article_count integer DEFAULT 0,
    blog_article_count integer DEFAULT 0,
    caption text,
    key_vote_category_id integer
);


--
-- Name: bills_committees; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bills_committees (
    id integer NOT NULL,
    bill_id integer,
    committee_id integer,
    activity character varying(255)
);


--
-- Name: bills_committees_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bills_committees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bills_committees_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bills_committees_id_seq OWNED BY bills_committees.id;


--
-- Name: bills_cosponsors; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bills_cosponsors (
    id integer NOT NULL,
    person_id integer,
    bill_id integer,
    date_added date,
    date_withdrawn date
);


--
-- Name: bills_cosponsors_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bills_cosponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bills_cosponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bills_cosponsors_id_seq OWNED BY bills_cosponsors.id;


--
-- Name: bills_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bills_id_seq OWNED BY bills.id;


--
-- Name: bills_relations; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bills_relations (
    id integer NOT NULL,
    relation character varying(255),
    bill_id integer,
    related_bill_id integer
);


--
-- Name: bills_relations_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bills_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bills_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bills_relations_id_seq OWNED BY bills_relations.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    bookmarkable_type character varying(15) DEFAULT ''::character varying NOT NULL,
    bookmarkable_id integer DEFAULT 0 NOT NULL,
    user_id integer DEFAULT 0 NOT NULL
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: comment_scores; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE comment_scores (
    id integer NOT NULL,
    user_id integer,
    comment_id integer,
    score integer,
    created_at timestamp without time zone,
    ip_address character varying(255)
);


--
-- Name: comment_scores_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE comment_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comment_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE comment_scores_id_seq OWNED BY comment_scores.id;


--
-- Name: commentaries; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE commentaries (
    id integer NOT NULL,
    title character varying,
    url text,
    excerpt text,
    date timestamp without time zone,
    source character varying(255),
    source_url character varying(255),
    weight integer,
    scraped_from character varying(255),
    status character varying(255),
    contains_term character varying(255),
    fti_names tsvector,
    created_at timestamp without time zone,
    is_news boolean,
    is_ok boolean DEFAULT false,
    average_rating double precision,
    commentariable_id integer,
    commentariable_type character varying(255)
);


--
-- Name: commentaries_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE commentaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE commentaries_id_seq OWNED BY commentaries.id;


--
-- Name: commentary_ratings; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE commentary_ratings (
    id integer NOT NULL,
    user_id integer,
    commentary_id integer,
    rating integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: commentary_ratings_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE commentary_ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: commentary_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE commentary_ratings_id_seq OWNED BY commentary_ratings.id;


--
-- Name: comments; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_id integer,
    commentable_type character varying(255),
    comment text,
    user_id integer,
    name character varying(255),
    email character varying(255),
    homepage character varying(255),
    created_at timestamp without time zone,
    parent_id integer,
    title character varying(255),
    updated_at timestamp without time zone,
    average_rating double precision DEFAULT 5.0,
    censored boolean DEFAULT false,
    ok boolean,
    rgt integer,
    lft integer,
    root_id integer,
    fti_names tsvector,
    flagged boolean DEFAULT false,
    ip_address character varying(255),
    plus_score_count integer DEFAULT 0 NOT NULL,
    minus_score_count integer DEFAULT 0 NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: committee_meetings; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committee_meetings (
    id integer NOT NULL,
    subject text,
    meeting_at timestamp without time zone,
    committee_id integer,
    "where" character varying(255)
);


--
-- Name: committee_meetings_bills; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committee_meetings_bills (
    id integer NOT NULL,
    committee_meeting_id integer,
    bill_id integer
);


--
-- Name: committee_meetings_bills_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE committee_meetings_bills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: committee_meetings_bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE committee_meetings_bills_id_seq OWNED BY committee_meetings_bills.id;


--
-- Name: committee_meetings_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE committee_meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: committee_meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE committee_meetings_id_seq OWNED BY committee_meetings.id;


--
-- Name: committee_reports; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committee_reports (
    id integer NOT NULL,
    name character varying(255),
    index integer,
    number integer,
    kind character varying(255),
    person_id integer,
    bill_id integer,
    committee_id integer,
    congress integer,
    title text,
    reported_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: committee_reports_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE committee_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: committee_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE committee_reports_id_seq OWNED BY committee_reports.id;


--
-- Name: committee_stats; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committee_stats (
    committee_id integer NOT NULL,
    entered_top_viewed timestamp without time zone
);


--
-- Name: committees; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committees (
    id integer NOT NULL,
    name character varying(255),
    subcommittee_name character varying(255),
    fti_names tsvector,
    active boolean DEFAULT true,
    code character varying(255),
    page_views_count integer
);


--
-- Name: committees_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE committees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: committees_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE committees_id_seq OWNED BY committees.id;


--
-- Name: committees_people; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE committees_people (
    id integer NOT NULL,
    committee_id integer,
    person_id integer,
    role character varying(255),
    session integer
);


--
-- Name: committees_people_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE committees_people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: committees_people_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE committees_people_id_seq OWNED BY committees_people.id;


--
-- Name: comparison_data_points; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE comparison_data_points (
    id integer NOT NULL,
    comparison_id integer,
    comp_value integer,
    comp_indx integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comparison_data_points_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE comparison_data_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comparison_data_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE comparison_data_points_id_seq OWNED BY comparison_data_points.id;


--
-- Name: comparisons; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE comparisons (
    id integer NOT NULL,
    type character varying(255),
    congress integer,
    chamber character varying(255),
    average_value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comparisons_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE comparisons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comparisons_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE comparisons_id_seq OWNED BY comparisons.id;


--
-- Name: congress_sessions; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE congress_sessions (
    id integer NOT NULL,
    chamber character varying(255),
    date date,
    is_in_session boolean
);


--
-- Name: congress_sessions_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE congress_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: congress_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE congress_sessions_id_seq OWNED BY congress_sessions.id;


--
-- Name: contact_congress_letters; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE contact_congress_letters (
    id integer NOT NULL,
    user_id integer,
    bill_id integer,
    disposition character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    receive_replies boolean DEFAULT true
);


--
-- Name: contact_congress_letters_formageddon_threads; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE contact_congress_letters_formageddon_threads (
    contact_congress_letter_id integer,
    formageddon_thread_id integer
);


--
-- Name: contact_congress_letters_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE contact_congress_letters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: contact_congress_letters_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE contact_congress_letters_id_seq OWNED BY contact_congress_letters.id;


--
-- Name: crp_contrib_individual_to_candidate; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_contrib_individual_to_candidate (
    cycle character varying(255) NOT NULL,
    fec_trans_id character varying(255) NOT NULL,
    fec_contrib_id character varying(255),
    name character varying(255) NOT NULL,
    recipient_osid character varying(255),
    org character varying(255),
    parent_org character varying(255),
    crp_interest_group_osid character varying(255),
    contrib_date date NOT NULL,
    amount integer,
    street character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255),
    recip_code character varying(255),
    contrib_type character varying(255),
    pac_id character varying(255),
    other_pac_id character varying(255),
    gender character varying(255),
    fed_occ_emp character varying(255),
    microfilm character varying(255),
    occ_ef character varying(255),
    emp_ef character varying(255),
    source character varying(255)
);


--
-- Name: crp_contrib_pac_to_candidate; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_contrib_pac_to_candidate (
    cycle character varying(255) NOT NULL,
    fec_trans_id character varying(255) NOT NULL,
    crp_pac_osid character varying(255) NOT NULL,
    recipient_osid character varying(255),
    amount integer NOT NULL,
    contrib_date date NOT NULL,
    crp_interest_group_osid character varying(255),
    contrib_type character varying(255),
    direct_or_indirect character varying(255) NOT NULL,
    fec_cand_id character varying(255)
);


--
-- Name: crp_contrib_pac_to_pac; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_contrib_pac_to_pac (
    cycle character varying(255) NOT NULL,
    fec_trans_id character varying(255) NOT NULL,
    filer_osid character varying(255),
    donor_name character varying(255),
    filer_name character varying(255),
    donor_city character varying(255),
    donor_state character varying(255),
    donor_zip character varying(255),
    fed_occ_emp character varying(255),
    donor_crp_interest_group_osid character varying(255),
    contrib_date date NOT NULL,
    amount double precision,
    recipient_osid character varying(255),
    party character varying(255),
    other_id character varying(255),
    recipient_type character varying(255),
    recipient_crp_interest_group_osid character varying(255),
    amended character varying(255),
    report_type character varying(255),
    election_type character varying(255),
    microfilm character varying(255),
    contrib_type character varying(255),
    donor_realcode_crp_interest_group_osid character varying(255),
    realcode_source character varying(255)
);


--
-- Name: crp_industries; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_industries (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    crp_sector_id integer
);


--
-- Name: crp_industries_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE crp_industries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: crp_industries_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE crp_industries_id_seq OWNED BY crp_industries.id;


--
-- Name: crp_interest_groups; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_interest_groups (
    id integer NOT NULL,
    osid character varying(255) NOT NULL,
    name character varying(255),
    crp_industry_id integer,
    "order" character varying(255)
);


--
-- Name: crp_interest_groups_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE crp_interest_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: crp_interest_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE crp_interest_groups_id_seq OWNED BY crp_interest_groups.id;


--
-- Name: crp_pacs; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_pacs (
    id integer NOT NULL,
    fec_id character varying(255) NOT NULL,
    osid character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    affiliate_pac_id integer,
    parent_pac_id integer,
    recipient_type character varying(255),
    recipient_person_id integer,
    party character varying(255),
    crp_interest_group_id integer,
    crp_interest_group_source character varying(255),
    is_sensitive boolean DEFAULT false,
    is_foreign boolean DEFAULT false,
    is_active boolean DEFAULT true
);


--
-- Name: crp_pacs_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE crp_pacs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: crp_pacs_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE crp_pacs_id_seq OWNED BY crp_pacs.id;


--
-- Name: crp_sectors; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE crp_sectors (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255)
);


--
-- Name: crp_sectors_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE crp_sectors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: crp_sectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE crp_sectors_id_seq OWNED BY crp_sectors.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: districts; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE districts (
    id integer NOT NULL,
    district_number integer,
    state_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    center_lat numeric(15,10),
    center_lng numeric(15,10)
);


--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE districts_id_seq OWNED BY districts.id;


--
-- Name: facebook_templates; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE facebook_templates (
    id integer NOT NULL,
    template_name character varying(255) NOT NULL,
    content_hash character varying(255) NOT NULL,
    bundle_id character varying(255)
);


--
-- Name: facebook_templates_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE facebook_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: facebook_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE facebook_templates_id_seq OWNED BY facebook_templates.id;


--
-- Name: facebook_user_bills; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE facebook_user_bills (
    id integer NOT NULL,
    facebook_user_id integer,
    bill_id integer,
    tracking_type character varying(255),
    comment text,
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: facebook_user_bills_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE facebook_user_bills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: facebook_user_bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE facebook_user_bills_id_seq OWNED BY facebook_user_bills.id;


--
-- Name: facebook_users; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE facebook_users (
    id integer NOT NULL,
    facebook_uid integer,
    facebook_session_key character varying(255),
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: facebook_users_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE facebook_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: facebook_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE facebook_users_id_seq OWNED BY facebook_users.id;


--
-- Name: featured_people; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE featured_people (
    id integer NOT NULL,
    person_id integer,
    text text,
    updated_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: featured_people_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE featured_people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: featured_people_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE featured_people_id_seq OWNED BY featured_people.id;


--
-- Name: formageddon_browser_states; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_browser_states (
    id integer NOT NULL,
    uri text,
    cookie_jar text,
    raw_html text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: formageddon_browser_states_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_browser_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_browser_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_browser_states_id_seq OWNED BY formageddon_browser_states.id;


--
-- Name: formageddon_contact_steps; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_contact_steps (
    id integer NOT NULL,
    formageddon_recipient_id integer,
    formageddon_recipient_type character varying(255),
    step_number integer,
    command character varying(255)
);


--
-- Name: formageddon_contact_steps_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_contact_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_contact_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_contact_steps_id_seq OWNED BY formageddon_contact_steps.id;


--
-- Name: formageddon_delivery_attempts; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_delivery_attempts (
    id integer NOT NULL,
    formageddon_letter_id integer,
    result character varying(255),
    letter_contact_step integer,
    before_browser_state_id text,
    after_browser_state_id text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: formageddon_delivery_attempts_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_delivery_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_delivery_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_delivery_attempts_id_seq OWNED BY formageddon_delivery_attempts.id;


--
-- Name: formageddon_form_captcha_images; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_form_captcha_images (
    id integer NOT NULL,
    formageddon_form_id integer,
    image_number integer,
    css_selector character varying(255)
);


--
-- Name: formageddon_form_captcha_images_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_form_captcha_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_form_captcha_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_form_captcha_images_id_seq OWNED BY formageddon_form_captcha_images.id;


--
-- Name: formageddon_form_fields; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_form_fields (
    id integer NOT NULL,
    formageddon_form_id integer,
    field_number integer,
    name character varying(255),
    value character varying(255)
);


--
-- Name: formageddon_form_fields_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_form_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_form_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_form_fields_id_seq OWNED BY formageddon_form_fields.id;


--
-- Name: formageddon_forms; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_forms (
    id integer NOT NULL,
    formageddon_contact_step_id integer,
    form_number integer,
    use_field_names boolean,
    success_string character varying(255),
    use_real_email_address boolean DEFAULT false
);


--
-- Name: formageddon_forms_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_forms_id_seq OWNED BY formageddon_forms.id;


--
-- Name: formageddon_letters; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_letters (
    id integer NOT NULL,
    formageddon_thread_id integer,
    direction character varying(255),
    status character varying(255),
    issue_area character varying(255),
    subject character varying(255),
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: formageddon_letters_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_letters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_letters_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_letters_id_seq OWNED BY formageddon_letters.id;


--
-- Name: formageddon_threads; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE formageddon_threads (
    id integer NOT NULL,
    formageddon_recipient_id integer,
    formageddon_recipient_type character varying(255),
    sender_title character varying(255),
    sender_first_name character varying(255),
    sender_last_name character varying(255),
    sender_address1 character varying(255),
    sender_address2 character varying(255),
    sender_city character varying(255),
    sender_state character varying(255),
    sender_zip5 character varying(255),
    sender_zip4 character varying(255),
    sender_phone character varying(255),
    sender_email character varying(255),
    privacy character varying(255),
    formageddon_sender_id integer,
    formageddon_sender_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: formageddon_threads_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE formageddon_threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: formageddon_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE formageddon_threads_id_seq OWNED BY formageddon_threads.id;


--
-- Name: friend_emails; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE friend_emails (
    id integer NOT NULL,
    emailable_id integer NOT NULL,
    emailable_type character varying(255),
    created_at timestamp without time zone,
    ip_address character varying(255)
);


--
-- Name: friend_emails_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE friend_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: friend_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE friend_emails_id_seq OWNED BY friend_emails.id;


--
-- Name: friend_invites; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE friend_invites (
    id integer NOT NULL,
    inviter_id integer,
    invitee_email character varying(255),
    created_at timestamp without time zone,
    invite_key character varying(255)
);


--
-- Name: friend_invites_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE friend_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: friend_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE friend_invites_id_seq OWNED BY friend_invites.id;


--
-- Name: friends; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE friends (
    id integer NOT NULL,
    user_id integer,
    friend_id integer,
    confirmed boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    confirmed_at timestamp without time zone
);


--
-- Name: friends_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE friends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: friends_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE friends_id_seq OWNED BY friends.id;


--
-- Name: fundraisers; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE fundraisers (
    id integer NOT NULL,
    sunlight_id integer,
    person_id integer,
    host character varying(255),
    beneficiaries character varying(255),
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    venue character varying(255),
    entertainment_type character varying(255),
    venue_address1 character varying(255),
    venue_address2 character varying(255),
    venue_city character varying(255),
    venue_state character varying(255),
    venue_zipcode character varying(255),
    venue_website character varying(255),
    contributions_info character varying(255),
    latlong character varying(255),
    rsvp_info character varying(255),
    distribution_payer character varying(255),
    make_checks_payable_to character varying(255),
    checks_payable_address character varying(255),
    committee_id character varying(255)
);


--
-- Name: fundraisers_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE fundraisers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fundraisers_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE fundraisers_id_seq OWNED BY fundraisers.id;


--
-- Name: gossip; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE gossip (
    id integer NOT NULL,
    name character varying(255),
    title character varying(255),
    email character varying(255),
    link character varying(255),
    tip text,
    frontpage boolean DEFAULT false,
    approved boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gossip_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE gossip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gossip_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE gossip_id_seq OWNED BY gossip.id;


--
-- Name: gpo_billtext_timestamps; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE gpo_billtext_timestamps (
    id integer NOT NULL,
    session integer,
    bill_type character varying(255),
    number integer,
    version character varying(255),
    created_at timestamp without time zone
);


--
-- Name: gpo_billtext_timestamps_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE gpo_billtext_timestamps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gpo_billtext_timestamps_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE gpo_billtext_timestamps_id_seq OWNED BY gpo_billtext_timestamps.id;


--
-- Name: group_bill_positions; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE group_bill_positions (
    id integer NOT NULL,
    group_id integer,
    bill_id integer,
    "position" character varying(255),
    comment character varying(255),
    permalink character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: group_bill_positions_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE group_bill_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: group_bill_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE group_bill_positions_id_seq OWNED BY group_bill_positions.id;


--
-- Name: group_invites; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE group_invites (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    email character varying(255),
    key character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: group_invites_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE group_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: group_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE group_invites_id_seq OWNED BY group_invites.id;


--
-- Name: group_members; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE group_members (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    status character varying(255),
    receive_owner_emails boolean DEFAULT true,
    last_view timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE group_members_id_seq OWNED BY group_members.id;


--
-- Name: groups; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    user_id integer,
    name character varying(255),
    description text,
    join_type character varying(255),
    invite_type character varying(255),
    post_type character varying(255),
    publicly_visible boolean DEFAULT true,
    website character varying(255),
    pvs_category_id integer,
    group_image_file_name character varying(255),
    group_image_content_type character varying(255),
    group_image_file_size integer,
    group_image_updated_at timestamp without time zone,
    state_id integer,
    district_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: hot_bill_categories; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE hot_bill_categories (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: hot_bill_categories_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE hot_bill_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: hot_bill_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE hot_bill_categories_id_seq OWNED BY hot_bill_categories.id;


--
-- Name: industry_stats; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE industry_stats (
    sector_id integer NOT NULL,
    entered_top_viewed timestamp without time zone
);


--
-- Name: issue_stats; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE issue_stats (
    subject_id integer NOT NULL,
    entered_top_viewed timestamp without time zone
);


--
-- Name: mailing_list_items; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE mailing_list_items (
    id integer NOT NULL,
    mailable_type character varying(255),
    mailable_id integer,
    user_mailing_list_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mailing_list_items_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE mailing_list_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: mailing_list_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE mailing_list_items_id_seq OWNED BY mailing_list_items.id;


--
-- Name: notebook_items; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE notebook_items (
    id integer NOT NULL,
    political_notebook_id integer,
    type character varying(255),
    url character varying(255),
    title character varying(255),
    date character varying(255),
    source character varying(255),
    description text,
    is_internal boolean,
    embed text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_id integer,
    size integer,
    width integer,
    height integer,
    filename character varying(255),
    content_type character varying(255),
    thumbnail character varying(255),
    notebookable_type character varying(255),
    notebookable_id integer,
    hot_bill_category_id integer,
    file_file_name character varying(255),
    file_content_type character varying(255),
    file_file_size integer,
    file_updated_at timestamp without time zone,
    group_user_id integer
);


--
-- Name: notebook_items_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE notebook_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: notebook_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE notebook_items_id_seq OWNED BY notebook_items.id;


--
-- Name: object_aggregates; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE object_aggregates (
    id integer NOT NULL,
    aggregatable_type character varying(255),
    aggregatable_id integer,
    date date,
    page_views_count integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    blog_articles_count integer DEFAULT 0,
    news_articles_count integer DEFAULT 0,
    bookmarks_count integer DEFAULT 0,
    votes_support integer DEFAULT 0,
    votes_oppose integer DEFAULT 0
);


--
-- Name: object_aggregates_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE object_aggregates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: object_aggregates_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE object_aggregates_id_seq OWNED BY object_aggregates.id;


--
-- Name: open_id_authentication_associations; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE open_id_authentication_associations (
    id integer NOT NULL,
    issued integer,
    lifetime integer,
    handle character varying(255),
    assoc_type character varying(255),
    server_url bytea,
    secret bytea
);


--
-- Name: open_id_authentication_associations_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE open_id_authentication_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: open_id_authentication_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE open_id_authentication_associations_id_seq OWNED BY open_id_authentication_associations.id;


--
-- Name: open_id_authentication_nonces; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE open_id_authentication_nonces (
    id integer NOT NULL,
    "timestamp" integer NOT NULL,
    server_url character varying(255),
    salt character varying(255) NOT NULL
);


--
-- Name: open_id_authentication_nonces_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE open_id_authentication_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: open_id_authentication_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE open_id_authentication_nonces_id_seq OWNED BY open_id_authentication_nonces.id;


--
-- Name: panel_referrers; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE panel_referrers (
    id integer NOT NULL,
    referrer_url text NOT NULL,
    panel_type character varying(255),
    views integer DEFAULT 0,
    updated_at timestamp without time zone
);


--
-- Name: panel_referrers_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE panel_referrers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: panel_referrers_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE panel_referrers_id_seq OWNED BY panel_referrers.id;


--
-- Name: people; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    firstname character varying(255),
    middlename character varying(255),
    lastname character varying(255),
    nickname character varying(255),
    birthday date,
    gender character varying(1),
    religion character varying(255),
    url character varying(255),
    party character varying(255),
    osid character varying(255),
    bioguideid character varying(255),
    title character varying(255),
    state character varying(255),
    district character varying(255),
    name character varying(255),
    email character varying(255),
    fti_names tsvector,
    user_approval double precision DEFAULT 5,
    biography text,
    unaccented_name character varying(255),
    metavid_id character varying(255),
    youtube_id character varying(255),
    website character varying(255),
    congress_office character varying(255),
    phone character varying(255),
    fax character varying(255),
    contact_webform character varying(255),
    sunlight_nickname character varying(255),
    watchdog_id character varying(255),
    page_views_count integer,
    news_article_count integer DEFAULT 0,
    blog_article_count integer DEFAULT 0,
    total_session_votes integer,
    votes_democratic_position integer,
    votes_republican_position integer
);


--
-- Name: people_cycle_contributions; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE people_cycle_contributions (
    id integer NOT NULL,
    person_id integer,
    total_raised integer,
    top_contributor_id integer,
    top_contributor_amount integer,
    cycle character varying(255),
    updated_at timestamp without time zone
);


--
-- Name: people_cycle_contributions_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE people_cycle_contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: people_cycle_contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE people_cycle_contributions_id_seq OWNED BY people_cycle_contributions.id;


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: person_approvals; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE person_approvals (
    id integer NOT NULL,
    user_id integer,
    rating integer,
    person_id integer,
    created_at timestamp without time zone,
    update_at timestamp without time zone
);


--
-- Name: person_approvals_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE person_approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: person_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE person_approvals_id_seq OWNED BY person_approvals.id;


--
-- Name: person_stats; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE person_stats (
    person_id integer NOT NULL,
    entered_top_viewed timestamp without time zone,
    votes_most_often_with_id integer,
    votes_least_often_with_id integer,
    opposing_party_votes_most_often_with_id integer,
    same_party_votes_least_often_with_id integer,
    entered_top_news timestamp without time zone,
    entered_top_blog timestamp without time zone,
    sponsored_bills integer,
    cosponsored_bills integer,
    sponsored_bills_passed integer,
    cosponsored_bills_passed integer,
    sponsored_bills_rank integer,
    cosponsored_bills_rank integer,
    sponsored_bills_passed_rank integer,
    cosponsored_bills_passed_rank integer,
    party_votes_percentage double precision,
    party_votes_percentage_rank integer,
    abstains_percentage double precision,
    abstains integer,
    abstains_percentage_rank integer
);


--
-- Name: political_notebooks; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE political_notebooks (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    group_id integer
);


--
-- Name: political_notebooks_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE political_notebooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: political_notebooks_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE political_notebooks_id_seq OWNED BY political_notebooks.id;


--
-- Name: privacy_options; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE privacy_options (
    id integer NOT NULL,
    my_full_name integer DEFAULT 0,
    my_email integer DEFAULT 0,
    my_last_login_date integer DEFAULT 0,
    my_zip_code integer DEFAULT 0,
    my_instant_messanger_names integer DEFAULT 0,
    my_website integer DEFAULT 0,
    my_location integer DEFAULT 0,
    about_me integer DEFAULT 0,
    my_actions integer DEFAULT 0,
    my_tracked_items integer DEFAULT 0,
    my_friends integer DEFAULT 0,
    my_congressional_district integer DEFAULT 0,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    my_political_notebook integer DEFAULT 2,
    watchdog integer DEFAULT 2
);


--
-- Name: privacy_options_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE privacy_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: privacy_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE privacy_options_id_seq OWNED BY privacy_options.id;


--
-- Name: pvs_categories; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE pvs_categories (
    id integer NOT NULL,
    name character varying(255),
    pvs_id integer
);


--
-- Name: pvs_categories_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE pvs_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pvs_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE pvs_categories_id_seq OWNED BY pvs_categories.id;


--
-- Name: pvs_category_mappings; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE pvs_category_mappings (
    id integer NOT NULL,
    pvs_category_id integer,
    pvs_category_mappable_id integer,
    pvs_category_mappable_type character varying(255)
);


--
-- Name: pvs_category_mappings_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE pvs_category_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pvs_category_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE pvs_category_mappings_id_seq OWNED BY pvs_category_mappings.id;


--
-- Name: refers; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE refers (
    id integer NOT NULL,
    label character varying(255),
    ref character varying(255),
    action_id integer
);


--
-- Name: refers_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE refers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: refers_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE refers_id_seq OWNED BY refers.id;


--
-- Name: roles; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    person_id integer,
    role_type character varying(255),
    startdate date,
    enddate date,
    party character varying(255),
    state character varying(255),
    district character varying(255),
    url character varying(255),
    address character varying(255),
    phone character varying(255),
    email character varying(255)
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roll_call_votes; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE roll_call_votes (
    id integer NOT NULL,
    vote character varying(255),
    roll_call_id integer,
    person_id integer
);


--
-- Name: roll_call_votes_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE roll_call_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roll_call_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE roll_call_votes_id_seq OWNED BY roll_call_votes.id;


--
-- Name: roll_calls; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE roll_calls (
    id integer NOT NULL,
    number integer,
    "where" character varying(255),
    date timestamp without time zone,
    updated timestamp without time zone,
    roll_type character varying(255),
    question text,
    required character varying(255),
    result character varying(255),
    bill_id integer,
    amendment_id integer,
    filename character varying(255),
    ayes integer DEFAULT 0,
    nays integer DEFAULT 0,
    abstains integer DEFAULT 0,
    presents integer DEFAULT 0,
    democratic_position boolean,
    republican_position boolean,
    is_hot boolean DEFAULT false,
    title character varying(255),
    hot_date timestamp without time zone,
    page_views_count integer
);


--
-- Name: roll_calls_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE roll_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roll_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE roll_calls_id_seq OWNED BY roll_calls.id;


--
-- Name: searches; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE searches (
    id integer NOT NULL,
    search_text character varying(255),
    created_at timestamp without time zone
);


--
-- Name: searches_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE searches_id_seq OWNED BY searches.id;


--
-- Name: sidebar_boxes; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE sidebar_boxes (
    id integer NOT NULL,
    image_url character varying(255),
    box_html text,
    sidebarable_id integer,
    sidebarable_type character varying(255)
);


--
-- Name: sidebar_boxes_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE sidebar_boxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sidebar_boxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE sidebar_boxes_id_seq OWNED BY sidebar_boxes.id;


--
-- Name: simple_captcha_data; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE simple_captcha_data (
    id integer NOT NULL,
    key character varying(40),
    value character varying(6),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE simple_captcha_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE simple_captcha_data_id_seq OWNED BY simple_captcha_data.id;


--
-- Name: site_text_pages; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE site_text_pages (
    id integer NOT NULL,
    page_params character varying(255),
    title_tags character varying(255),
    meta_description text,
    meta_keywords character varying(255),
    title_desc text,
    page_text_editable_type text,
    page_text_editable_id integer
);


--
-- Name: site_text_pages_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE site_text_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: site_text_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE site_text_pages_id_seq OWNED BY site_text_pages.id;


--
-- Name: site_texts; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE site_texts (
    id integer NOT NULL,
    text_type character varying(255),
    text text,
    updated_at timestamp without time zone
);


--
-- Name: site_texts_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE site_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: site_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE site_texts_id_seq OWNED BY site_texts.id;


--
-- Name: states; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255),
    abbreviation character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: subject_relations; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE subject_relations (
    id integer NOT NULL,
    subject_id integer,
    related_subject_id integer,
    relation_count integer
);


--
-- Name: subject_relations_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE subject_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE subject_relations_id_seq OWNED BY subject_relations.id;


--
-- Name: subjects; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE subjects (
    id integer NOT NULL,
    term character varying(255),
    bill_count integer,
    fti_names tsvector,
    page_views_count integer
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: taggings; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    tagger_id integer,
    tagger_type character varying(255),
    taggable_type character varying(255),
    context character varying(255),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: talking_points; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE talking_points (
    id integer NOT NULL,
    talking_pointable_id integer,
    talking_pointable_type character varying(255),
    talking_point character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: talking_points_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE talking_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: talking_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE talking_points_id_seq OWNED BY talking_points.id;


--
-- Name: twitter_configs; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE twitter_configs (
    id integer NOT NULL,
    user_id integer,
    secret character varying(255),
    token character varying(255),
    tracking boolean,
    bill_votes boolean,
    person_approvals boolean,
    new_notebook_items boolean,
    logins boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: twitter_configs_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE twitter_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: twitter_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE twitter_configs_id_seq OWNED BY twitter_configs.id;


--
-- Name: upcoming_bills; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE upcoming_bills (
    id integer NOT NULL,
    title text,
    summary text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fti_names tsvector
);


--
-- Name: upcoming_bills_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE upcoming_bills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: upcoming_bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE upcoming_bills_id_seq OWNED BY upcoming_bills.id;


--
-- Name: user_audits; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE user_audits (
    id integer NOT NULL,
    user_id integer,
    email character varying(255),
    email_was character varying(255),
    full_name character varying(255),
    district character varying(255),
    zipcode character varying(255),
    state character varying(255),
    created_at timestamp without time zone,
    processed boolean DEFAULT false NOT NULL,
    mailing boolean DEFAULT false NOT NULL
);


--
-- Name: user_audits_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE user_audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE user_audits_id_seq OWNED BY user_audits.id;


--
-- Name: user_ip_addresses; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE user_ip_addresses (
    id integer NOT NULL,
    user_id integer,
    addr bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_ip_addresses_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE user_ip_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_ip_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE user_ip_addresses_id_seq OWNED BY user_ip_addresses.id;


--
-- Name: user_mailing_lists; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE user_mailing_lists (
    id integer NOT NULL,
    user_id integer,
    last_processed timestamp without time zone,
    status integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_mailing_lists_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE user_mailing_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_mailing_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE user_mailing_lists_id_seq OWNED BY user_mailing_lists.id;


--
-- Name: user_roles; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE user_roles (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying,
    can_blog boolean DEFAULT false,
    can_administer_users boolean DEFAULT false,
    can_see_stats boolean DEFAULT false,
    can_manage_text boolean DEFAULT false,
    can_moderate_articles boolean DEFAULT false,
    can_edit_blog_tags boolean DEFAULT false
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE user_roles_id_seq OWNED BY user_roles.id;


--
-- Name: user_warnings; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE user_warnings (
    id integer NOT NULL,
    user_id integer,
    warning_message text,
    warned_by integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_warnings_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE user_warnings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_warnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE user_warnings_id_seq OWNED BY user_warnings.id;


--
-- Name: users; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(255),
    password character varying(255),
    admin boolean DEFAULT false,
    blog_author boolean DEFAULT false,
    full_name character varying(255),
    email character varying(255),
    crypted_password character varying(40),
    salt character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_token character varying(255),
    remember_created_at timestamp without time zone,
    status integer,
    last_login timestamp without time zone,
    location character varying(255),
    show_email boolean DEFAULT false,
    show_homepage boolean DEFAULT false,
    homepage character varying(255),
    subscribed boolean DEFAULT false,
    activation_code character varying(40),
    activated_at timestamp without time zone,
    password_reset_code character varying(40),
    zipcode character varying(5),
    mailing boolean DEFAULT false,
    accept_terms boolean,
    about text,
    main_picture character varying(255),
    small_picture character varying(255),
    chat_aim character varying(255),
    chat_yahoo character varying(255),
    chat_msn character varying(255),
    chat_icq character varying(255),
    chat_gtalk character varying(255),
    show_aim boolean DEFAULT false,
    show_full_name boolean DEFAULT false,
    default_filter integer DEFAULT 5,
    user_role_id integer DEFAULT 0,
    enabled boolean DEFAULT true,
    representative_id integer,
    zip_four character varying(4),
    previous_login_date timestamp without time zone,
    identity_url character varying(255),
    feed_key character varying(255),
    district_cache text,
    state_cache text,
    is_banned boolean DEFAULT false,
    accepted_tos boolean DEFAULT false,
    accepted_tos_at timestamp without time zone,
    partner_mailing boolean DEFAULT false,
    authentication_token character varying(255),
    facebook_uid character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: v_current_roles; Type: VIEW; Schema: public;
--

CREATE VIEW v_current_roles AS
    SELECT states.id AS state_id, roles.id AS role_id, people.id AS person_id, roles.role_type FROM ((people JOIN roles ON ((roles.person_id = people.id))) JOIN states ON (((people.state)::text = (states.abbreviation)::text))) WHERE (roles.enddate > now());


--
-- Name: videos; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE videos (
    id integer NOT NULL,
    person_id integer,
    bill_id integer,
    embed text,
    title character varying(255),
    source character varying(255),
    video_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text,
    url character varying(255),
    length integer
);


--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE videos_id_seq OWNED BY videos.id;


--
-- Name: watch_dogs; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE watch_dogs (
    id integer NOT NULL,
    district_id integer,
    user_id integer,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: watch_dogs_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE watch_dogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: watch_dogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE watch_dogs_id_seq OWNED BY watch_dogs.id;


--
-- Name: wiki_links; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE wiki_links (
    id integer NOT NULL,
    wikiable_type character varying(255),
    wikiable_id integer,
    name character varying(255),
    oc_link character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wiki_links_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE wiki_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: wiki_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE wiki_links_id_seq OWNED BY wiki_links.id;


--
-- Name: write_rep_email_msgids; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE write_rep_email_msgids (
    id integer NOT NULL,
    write_rep_email_id integer,
    person_id integer,
    status character varying(255),
    msgid integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: write_rep_email_msgids_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE write_rep_email_msgids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: write_rep_email_msgids_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE write_rep_email_msgids_id_seq OWNED BY write_rep_email_msgids.id;


--
-- Name: write_rep_emails; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE write_rep_emails (
    id integer NOT NULL,
    user_id integer,
    prefix character varying(255),
    fname character varying(255),
    lname character varying(255),
    address character varying(255),
    zip5 character varying(255),
    zip4 character varying(255),
    city character varying(255),
    state character varying(255),
    district character varying(255),
    person_id integer,
    email character varying(255),
    phone character varying(255),
    subject character varying(255),
    msg text,
    result character varying(255),
    ip_address character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: write_rep_emails_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE write_rep_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: write_rep_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public;
--

ALTER SEQUENCE write_rep_emails_id_seq OWNED BY write_rep_emails.id;


--
-- Name: zipcode_districts; Type: TABLE; Schema: public;; Tablespace: 
--

CREATE TABLE zipcode_districts (
    zip5 character(5) NOT NULL,
    zip4 character(4) NOT NULL,
    state character(2),
    district smallint
);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE action_references ALTER COLUMN id SET DEFAULT nextval('action_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE actions ALTER COLUMN id SET DEFAULT nextval('actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE amendments ALTER COLUMN id SET DEFAULT nextval('amendments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE api_hits ALTER COLUMN id SET DEFAULT nextval('api_hits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE article_images ALTER COLUMN id SET DEFAULT nextval('article_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE articles ALTER COLUMN id SET DEFAULT nextval('articles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bad_commentaries ALTER COLUMN id SET DEFAULT nextval('bad_commentaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_battles ALTER COLUMN id SET DEFAULT nextval('bill_battles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_interest_groups ALTER COLUMN id SET DEFAULT nextval('bill_interest_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_position_organizations ALTER COLUMN id SET DEFAULT nextval('bill_position_organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_referrers ALTER COLUMN id SET DEFAULT nextval('bill_referrers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_subjects ALTER COLUMN id SET DEFAULT nextval('bill_subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_text_nodes ALTER COLUMN id SET DEFAULT nextval('bill_text_nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_text_versions ALTER COLUMN id SET DEFAULT nextval('bill_text_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_titles ALTER COLUMN id SET DEFAULT nextval('bill_titles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bill_votes ALTER COLUMN id SET DEFAULT nextval('bill_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bills ALTER COLUMN id SET DEFAULT nextval('bills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bills_committees ALTER COLUMN id SET DEFAULT nextval('bills_committees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bills_cosponsors ALTER COLUMN id SET DEFAULT nextval('bills_cosponsors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bills_relations ALTER COLUMN id SET DEFAULT nextval('bills_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE comment_scores ALTER COLUMN id SET DEFAULT nextval('comment_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE commentaries ALTER COLUMN id SET DEFAULT nextval('commentaries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE commentary_ratings ALTER COLUMN id SET DEFAULT nextval('commentary_ratings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE committee_meetings ALTER COLUMN id SET DEFAULT nextval('committee_meetings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE committee_meetings_bills ALTER COLUMN id SET DEFAULT nextval('committee_meetings_bills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE committee_reports ALTER COLUMN id SET DEFAULT nextval('committee_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE committees ALTER COLUMN id SET DEFAULT nextval('committees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE committees_people ALTER COLUMN id SET DEFAULT nextval('committees_people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE comparison_data_points ALTER COLUMN id SET DEFAULT nextval('comparison_data_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE comparisons ALTER COLUMN id SET DEFAULT nextval('comparisons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE congress_sessions ALTER COLUMN id SET DEFAULT nextval('congress_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE contact_congress_letters ALTER COLUMN id SET DEFAULT nextval('contact_congress_letters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE crp_industries ALTER COLUMN id SET DEFAULT nextval('crp_industries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE crp_interest_groups ALTER COLUMN id SET DEFAULT nextval('crp_interest_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE crp_pacs ALTER COLUMN id SET DEFAULT nextval('crp_pacs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE crp_sectors ALTER COLUMN id SET DEFAULT nextval('crp_sectors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE districts ALTER COLUMN id SET DEFAULT nextval('districts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE facebook_templates ALTER COLUMN id SET DEFAULT nextval('facebook_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE facebook_user_bills ALTER COLUMN id SET DEFAULT nextval('facebook_user_bills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE facebook_users ALTER COLUMN id SET DEFAULT nextval('facebook_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE featured_people ALTER COLUMN id SET DEFAULT nextval('featured_people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_browser_states ALTER COLUMN id SET DEFAULT nextval('formageddon_browser_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_contact_steps ALTER COLUMN id SET DEFAULT nextval('formageddon_contact_steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_delivery_attempts ALTER COLUMN id SET DEFAULT nextval('formageddon_delivery_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_form_captcha_images ALTER COLUMN id SET DEFAULT nextval('formageddon_form_captcha_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_form_fields ALTER COLUMN id SET DEFAULT nextval('formageddon_form_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_forms ALTER COLUMN id SET DEFAULT nextval('formageddon_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_letters ALTER COLUMN id SET DEFAULT nextval('formageddon_letters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE formageddon_threads ALTER COLUMN id SET DEFAULT nextval('formageddon_threads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE friend_emails ALTER COLUMN id SET DEFAULT nextval('friend_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE friend_invites ALTER COLUMN id SET DEFAULT nextval('friend_invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE friends ALTER COLUMN id SET DEFAULT nextval('friends_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE fundraisers ALTER COLUMN id SET DEFAULT nextval('fundraisers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE gossip ALTER COLUMN id SET DEFAULT nextval('gossip_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE gpo_billtext_timestamps ALTER COLUMN id SET DEFAULT nextval('gpo_billtext_timestamps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE group_bill_positions ALTER COLUMN id SET DEFAULT nextval('group_bill_positions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE group_invites ALTER COLUMN id SET DEFAULT nextval('group_invites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE group_members ALTER COLUMN id SET DEFAULT nextval('group_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE hot_bill_categories ALTER COLUMN id SET DEFAULT nextval('hot_bill_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE mailing_list_items ALTER COLUMN id SET DEFAULT nextval('mailing_list_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE notebook_items ALTER COLUMN id SET DEFAULT nextval('notebook_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE object_aggregates ALTER COLUMN id SET DEFAULT nextval('object_aggregates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE open_id_authentication_associations ALTER COLUMN id SET DEFAULT nextval('open_id_authentication_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE open_id_authentication_nonces ALTER COLUMN id SET DEFAULT nextval('open_id_authentication_nonces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE panel_referrers ALTER COLUMN id SET DEFAULT nextval('panel_referrers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE people_cycle_contributions ALTER COLUMN id SET DEFAULT nextval('people_cycle_contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE person_approvals ALTER COLUMN id SET DEFAULT nextval('person_approvals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE political_notebooks ALTER COLUMN id SET DEFAULT nextval('political_notebooks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE privacy_options ALTER COLUMN id SET DEFAULT nextval('privacy_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE pvs_categories ALTER COLUMN id SET DEFAULT nextval('pvs_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE pvs_category_mappings ALTER COLUMN id SET DEFAULT nextval('pvs_category_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE refers ALTER COLUMN id SET DEFAULT nextval('refers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE roll_call_votes ALTER COLUMN id SET DEFAULT nextval('roll_call_votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE roll_calls ALTER COLUMN id SET DEFAULT nextval('roll_calls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE searches ALTER COLUMN id SET DEFAULT nextval('searches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE sidebar_boxes ALTER COLUMN id SET DEFAULT nextval('sidebar_boxes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE simple_captcha_data ALTER COLUMN id SET DEFAULT nextval('simple_captcha_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE site_text_pages ALTER COLUMN id SET DEFAULT nextval('site_text_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE site_texts ALTER COLUMN id SET DEFAULT nextval('site_texts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE subject_relations ALTER COLUMN id SET DEFAULT nextval('subject_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE talking_points ALTER COLUMN id SET DEFAULT nextval('talking_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE twitter_configs ALTER COLUMN id SET DEFAULT nextval('twitter_configs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE upcoming_bills ALTER COLUMN id SET DEFAULT nextval('upcoming_bills_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE user_audits ALTER COLUMN id SET DEFAULT nextval('user_audits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE user_ip_addresses ALTER COLUMN id SET DEFAULT nextval('user_ip_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE user_mailing_lists ALTER COLUMN id SET DEFAULT nextval('user_mailing_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE user_roles ALTER COLUMN id SET DEFAULT nextval('user_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE user_warnings ALTER COLUMN id SET DEFAULT nextval('user_warnings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE videos ALTER COLUMN id SET DEFAULT nextval('videos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE watch_dogs ALTER COLUMN id SET DEFAULT nextval('watch_dogs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE wiki_links ALTER COLUMN id SET DEFAULT nextval('wiki_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE write_rep_email_msgids ALTER COLUMN id SET DEFAULT nextval('write_rep_email_msgids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public;
--

ALTER TABLE write_rep_emails ALTER COLUMN id SET DEFAULT nextval('write_rep_emails_id_seq'::regclass);


--
-- Name: action_references_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY action_references
    ADD CONSTRAINT action_references_pkey PRIMARY KEY (id);


--
-- Name: actions_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: amendments_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY amendments
    ADD CONSTRAINT amendments_pkey PRIMARY KEY (id);


--
-- Name: api_hits_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY api_hits
    ADD CONSTRAINT api_hits_pkey PRIMARY KEY (id);


--
-- Name: article_images_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY article_images
    ADD CONSTRAINT article_images_pkey PRIMARY KEY (id);


--
-- Name: articles_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: bill_battles_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_battles
    ADD CONSTRAINT bill_battles_pkey PRIMARY KEY (id);


--
-- Name: bill_interest_groups_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_interest_groups
    ADD CONSTRAINT bill_interest_groups_pkey PRIMARY KEY (id);


--
-- Name: bill_position_organizations_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_position_organizations
    ADD CONSTRAINT bill_position_organizations_pkey PRIMARY KEY (id);


--
-- Name: bill_referrers_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_referrers
    ADD CONSTRAINT bill_referrers_pkey PRIMARY KEY (id);


--
-- Name: bill_subjects_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_subjects
    ADD CONSTRAINT bill_subjects_pkey PRIMARY KEY (id);


--
-- Name: bill_text_nodes_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_text_nodes
    ADD CONSTRAINT bill_text_nodes_pkey PRIMARY KEY (id);


--
-- Name: bill_text_versions_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_text_versions
    ADD CONSTRAINT bill_text_versions_pkey PRIMARY KEY (id);


--
-- Name: bill_titles_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_titles
    ADD CONSTRAINT bill_titles_pkey PRIMARY KEY (id);


--
-- Name: bill_votes_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bill_votes
    ADD CONSTRAINT bill_votes_pkey PRIMARY KEY (id);


--
-- Name: bills_committees_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bills_committees
    ADD CONSTRAINT bills_committees_pkey PRIMARY KEY (id);


--
-- Name: bills_cosponsors_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bills_cosponsors
    ADD CONSTRAINT bills_cosponsors_pkey PRIMARY KEY (id);


--
-- Name: bills_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);


--
-- Name: bills_relations_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bills_relations
    ADD CONSTRAINT bills_relations_pkey PRIMARY KEY (id);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: comment_scores_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY comment_scores
    ADD CONSTRAINT comment_scores_pkey PRIMARY KEY (id);


--
-- Name: commentaries_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY commentaries
    ADD CONSTRAINT commentaries_pkey PRIMARY KEY (id);


--
-- Name: commentary_ratings_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY commentary_ratings
    ADD CONSTRAINT commentary_ratings_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: commitees_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY committees
    ADD CONSTRAINT commitees_pkey PRIMARY KEY (id);


--
-- Name: committee_meetings_bills_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY committee_meetings_bills
    ADD CONSTRAINT committee_meetings_bills_pkey PRIMARY KEY (id);


--
-- Name: committee_meetings_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY committee_meetings
    ADD CONSTRAINT committee_meetings_pkey PRIMARY KEY (id);


--
-- Name: committee_reports_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY committee_reports
    ADD CONSTRAINT committee_reports_pkey PRIMARY KEY (id);


--
-- Name: committees_people_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY committees_people
    ADD CONSTRAINT committees_people_pkey PRIMARY KEY (id);


--
-- Name: comparison_data_points_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY comparison_data_points
    ADD CONSTRAINT comparison_data_points_pkey PRIMARY KEY (id);


--
-- Name: comparisons_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY comparisons
    ADD CONSTRAINT comparisons_pkey PRIMARY KEY (id);


--
-- Name: congress_sessions_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY congress_sessions
    ADD CONSTRAINT congress_sessions_pkey PRIMARY KEY (id);


--
-- Name: contact_congress_letters_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY contact_congress_letters
    ADD CONSTRAINT contact_congress_letters_pkey PRIMARY KEY (id);


--
-- Name: crp_industries_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY crp_industries
    ADD CONSTRAINT crp_industries_pkey PRIMARY KEY (id);


--
-- Name: crp_interest_groups_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY crp_interest_groups
    ADD CONSTRAINT crp_interest_groups_pkey PRIMARY KEY (id);


--
-- Name: crp_pacs_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY crp_pacs
    ADD CONSTRAINT crp_pacs_pkey PRIMARY KEY (id);


--
-- Name: crp_sectors_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY crp_sectors
    ADD CONSTRAINT crp_sectors_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: districts_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: facebook_templates_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY facebook_templates
    ADD CONSTRAINT facebook_templates_pkey PRIMARY KEY (id);


--
-- Name: facebook_user_bills_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY facebook_user_bills
    ADD CONSTRAINT facebook_user_bills_pkey PRIMARY KEY (id);


--
-- Name: facebook_users_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY facebook_users
    ADD CONSTRAINT facebook_users_pkey PRIMARY KEY (id);


--
-- Name: featured_people_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY featured_people
    ADD CONSTRAINT featured_people_pkey PRIMARY KEY (id);


--
-- Name: formageddon_browser_states_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_browser_states
    ADD CONSTRAINT formageddon_browser_states_pkey PRIMARY KEY (id);


--
-- Name: formageddon_contact_steps_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_contact_steps
    ADD CONSTRAINT formageddon_contact_steps_pkey PRIMARY KEY (id);


--
-- Name: formageddon_delivery_attempts_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_delivery_attempts
    ADD CONSTRAINT formageddon_delivery_attempts_pkey PRIMARY KEY (id);


--
-- Name: formageddon_form_captcha_images_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_form_captcha_images
    ADD CONSTRAINT formageddon_form_captcha_images_pkey PRIMARY KEY (id);


--
-- Name: formageddon_form_fields_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_form_fields
    ADD CONSTRAINT formageddon_form_fields_pkey PRIMARY KEY (id);


--
-- Name: formageddon_forms_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_forms
    ADD CONSTRAINT formageddon_forms_pkey PRIMARY KEY (id);


--
-- Name: formageddon_letters_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_letters
    ADD CONSTRAINT formageddon_letters_pkey PRIMARY KEY (id);


--
-- Name: formageddon_threads_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY formageddon_threads
    ADD CONSTRAINT formageddon_threads_pkey PRIMARY KEY (id);


--
-- Name: friend_emails_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY friend_emails
    ADD CONSTRAINT friend_emails_pkey PRIMARY KEY (id);


--
-- Name: friend_invites_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY friend_invites
    ADD CONSTRAINT friend_invites_pkey PRIMARY KEY (id);


--
-- Name: friends_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (id);


--
-- Name: fundraisers_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY fundraisers
    ADD CONSTRAINT fundraisers_pkey PRIMARY KEY (id);


--
-- Name: gossip_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY gossip
    ADD CONSTRAINT gossip_pkey PRIMARY KEY (id);


--
-- Name: gpo_billtext_timestamps_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY gpo_billtext_timestamps
    ADD CONSTRAINT gpo_billtext_timestamps_pkey PRIMARY KEY (id);


--
-- Name: group_bill_positions_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY group_bill_positions
    ADD CONSTRAINT group_bill_positions_pkey PRIMARY KEY (id);


--
-- Name: group_invites_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY group_invites
    ADD CONSTRAINT group_invites_pkey PRIMARY KEY (id);


--
-- Name: group_members_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: hot_bill_categories_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY hot_bill_categories
    ADD CONSTRAINT hot_bill_categories_pkey PRIMARY KEY (id);


--
-- Name: mailing_list_items_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY mailing_list_items
    ADD CONSTRAINT mailing_list_items_pkey PRIMARY KEY (id);


--
-- Name: notebook_items_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY notebook_items
    ADD CONSTRAINT notebook_items_pkey PRIMARY KEY (id);


--
-- Name: object_aggregates_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY object_aggregates
    ADD CONSTRAINT object_aggregates_pkey PRIMARY KEY (id);


--
-- Name: open_id_authentication_associations_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY open_id_authentication_associations
    ADD CONSTRAINT open_id_authentication_associations_pkey PRIMARY KEY (id);


--
-- Name: open_id_authentication_nonces_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY open_id_authentication_nonces
    ADD CONSTRAINT open_id_authentication_nonces_pkey PRIMARY KEY (id);


--
-- Name: panel_referrers_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY panel_referrers
    ADD CONSTRAINT panel_referrers_pkey PRIMARY KEY (id);


--
-- Name: people_cycle_contributions_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY people_cycle_contributions
    ADD CONSTRAINT people_cycle_contributions_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: person_approvals_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY person_approvals
    ADD CONSTRAINT person_approvals_pkey PRIMARY KEY (id);


--
-- Name: political_notebooks_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY political_notebooks
    ADD CONSTRAINT political_notebooks_pkey PRIMARY KEY (id);


--
-- Name: privacy_options_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY privacy_options
    ADD CONSTRAINT privacy_options_pkey PRIMARY KEY (id);


--
-- Name: pvs_categories_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY pvs_categories
    ADD CONSTRAINT pvs_categories_pkey PRIMARY KEY (id);


--
-- Name: pvs_category_mappings_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY pvs_category_mappings
    ADD CONSTRAINT pvs_category_mappings_pkey PRIMARY KEY (id);


--
-- Name: refers_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY refers
    ADD CONSTRAINT refers_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roll_call_votes_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY roll_call_votes
    ADD CONSTRAINT roll_call_votes_pkey PRIMARY KEY (id);


--
-- Name: roll_calls_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY roll_calls
    ADD CONSTRAINT roll_calls_pkey PRIMARY KEY (id);


--
-- Name: searches_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY searches
    ADD CONSTRAINT searches_pkey PRIMARY KEY (id);


--
-- Name: sidebar_boxes_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY sidebar_boxes
    ADD CONSTRAINT sidebar_boxes_pkey PRIMARY KEY (id);


--
-- Name: simple_captcha_data_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY simple_captcha_data
    ADD CONSTRAINT simple_captcha_data_pkey PRIMARY KEY (id);


--
-- Name: site_text_pages_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY site_text_pages
    ADD CONSTRAINT site_text_pages_pkey PRIMARY KEY (id);


--
-- Name: site_texts_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY site_texts
    ADD CONSTRAINT site_texts_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: subject_relations_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY subject_relations
    ADD CONSTRAINT subject_relations_pkey PRIMARY KEY (id);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: talking_points_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY talking_points
    ADD CONSTRAINT talking_points_pkey PRIMARY KEY (id);


--
-- Name: twitter_configs_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY twitter_configs
    ADD CONSTRAINT twitter_configs_pkey PRIMARY KEY (id);


--
-- Name: upcoming_bills_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY upcoming_bills
    ADD CONSTRAINT upcoming_bills_pkey PRIMARY KEY (id);


--
-- Name: user_audits_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY user_audits
    ADD CONSTRAINT user_audits_pkey PRIMARY KEY (id);


--
-- Name: user_ip_addresses_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY user_ip_addresses
    ADD CONSTRAINT user_ip_addresses_pkey PRIMARY KEY (id);


--
-- Name: user_mailing_lists_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY user_mailing_lists
    ADD CONSTRAINT user_mailing_lists_pkey PRIMARY KEY (id);


--
-- Name: user_roles_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_warnings_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY user_warnings
    ADD CONSTRAINT user_warnings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: videos_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: watch_dogs_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY watch_dogs
    ADD CONSTRAINT watch_dogs_pkey PRIMARY KEY (id);


--
-- Name: wiki_links_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY wiki_links
    ADD CONSTRAINT wiki_links_pkey PRIMARY KEY (id);


--
-- Name: write_rep_email_msgids_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY write_rep_email_msgids
    ADD CONSTRAINT write_rep_email_msgids_pkey PRIMARY KEY (id);


--
-- Name: write_rep_emails_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY write_rep_emails
    ADD CONSTRAINT write_rep_emails_pkey PRIMARY KEY (id);


--
-- Name: zipcode_districts_pkey; Type: CONSTRAINT; Schema: public;; Tablespace: 
--

ALTER TABLE ONLY zipcode_districts
    ADD CONSTRAINT zipcode_districts_pkey PRIMARY KEY (zip5, zip4);


--
-- Name: actions_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX actions_bill_id_index ON actions USING btree (bill_id);


--
-- Name: aggregatable_date_type_idx; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX aggregatable_date_type_idx ON object_aggregates USING btree (date, aggregatable_type);


--
-- Name: aggregatable_poly_idx; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX aggregatable_poly_idx ON object_aggregates USING btree (aggregatable_type, aggregatable_id);


--
-- Name: amendments_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX amendments_bill_id_index ON amendments USING btree (bill_id, number);


--
-- Name: articles_created_at_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX articles_created_at_index ON articles USING btree (created_at);


--
-- Name: articles_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX articles_fti_names_index ON articles USING gist (fti_names);


--
-- Name: bill_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_fti_names_index ON bill_fulltext USING gist (fti_names);


--
-- Name: bill_fulltext_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_fulltext_bill_id_index ON bill_fulltext USING btree (bill_id);


--
-- Name: bill_subjects_subject_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_subjects_subject_id_index ON bill_subjects USING btree (subject_id);


--
-- Name: bill_titles_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_titles_bill_id_index ON bill_titles USING btree (bill_id);


--
-- Name: bill_titles_fti_titles_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_titles_fti_titles_index ON bill_titles USING gist (fti_titles);


--
-- Name: bill_titles_title_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_titles_title_index ON bill_titles USING btree (title);


--
-- Name: bill_titles_upper_title_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bill_titles_upper_title_index ON bill_titles USING btree (upper(title));


--
-- Name: bills_committees_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bills_committees_bill_id_index ON bills_committees USING btree (bill_id, committee_id);


--
-- Name: bills_cosponsors_person_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bills_cosponsors_person_id_index ON bills_cosponsors USING btree (person_id, bill_id);


--
-- Name: bills_number_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bills_number_index ON bills USING btree (number, session, bill_type);


--
-- Name: bills_relations_bill_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bills_relations_bill_id_index ON bills_relations USING btree (bill_id, related_bill_id);


--
-- Name: bills_sponsor_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX bills_sponsor_id_index ON bills USING btree (sponsor_id);


--
-- Name: commentaries_url_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX commentaries_url_index ON commentaries USING btree (url);


--
-- Name: commentary_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX commentary_fti_names_index ON commentaries USING gist (fti_names);


--
-- Name: comments_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX comments_fti_names_index ON comments USING gist (fti_names);


--
-- Name: committee_reports_name_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX committee_reports_name_index ON committee_reports USING btree (name);


--
-- Name: committees_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX committees_fti_names_index ON committees USING gist (fti_names);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: friend_emails_created_at_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX friend_emails_created_at_index ON friend_emails USING btree (created_at);


--
-- Name: friend_emails_ip_address_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX friend_emails_ip_address_index ON friend_emails USING btree (ip_address);


--
-- Name: index_bad_commentaries_on_cid_and_ctype; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bad_commentaries_on_cid_and_ctype ON bad_commentaries USING btree (commentariable_id, commentariable_type);


--
-- Name: index_bad_commentaries_on_url; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bad_commentaries_on_url ON bad_commentaries USING btree (url);


--
-- Name: index_bill_referrers_on_bill_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_referrers_on_bill_id ON bill_referrers USING btree (bill_id);


--
-- Name: index_bill_referrers_on_url; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_referrers_on_url ON bill_referrers USING btree (url);


--
-- Name: index_bill_subjects_on_bill_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_subjects_on_bill_id ON bill_subjects USING btree (bill_id);


--
-- Name: index_bill_text_nodes_on_bill_text_version_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_text_nodes_on_bill_text_version_id ON bill_text_nodes USING btree (bill_text_version_id);


--
-- Name: index_bill_text_nodes_on_nid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_text_nodes_on_nid ON bill_text_nodes USING btree (nid);


--
-- Name: index_bill_text_versions_on_bill_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_text_versions_on_bill_id ON bill_text_versions USING btree (bill_id);


--
-- Name: index_bill_votes_on_bill_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_votes_on_bill_id ON bill_votes USING btree (bill_id);


--
-- Name: index_bill_votes_on_created_at; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_votes_on_created_at ON bill_votes USING btree (created_at);


--
-- Name: index_bill_votes_on_user_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bill_votes_on_user_id ON bill_votes USING btree (user_id);


--
-- Name: index_bills_on_hot_bill_category_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bills_on_hot_bill_category_id ON bills USING btree (hot_bill_category_id);


--
-- Name: index_bookmarks_on_bookmarkable_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bookmarks_on_bookmarkable_id ON bookmarks USING btree (bookmarkable_id);


--
-- Name: index_bookmarks_on_bookmarkable_type; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bookmarks_on_bookmarkable_type ON bookmarks USING btree (bookmarkable_type);


--
-- Name: index_bookmarks_on_user_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_bookmarks_on_user_id ON bookmarks USING btree (user_id);


--
-- Name: index_comment_scores_on_comment_id_and_ip_address; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comment_scores_on_comment_id_and_ip_address ON comment_scores USING btree (comment_id, ip_address);


--
-- Name: index_commentaries_on_commentariable_id_and_commentariable_type; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_commentaries_on_commentariable_id_and_commentariable_type ON commentaries USING btree (commentariable_id, commentariable_type, is_ok, is_news);


--
-- Name: index_commentaries_on_commentariable_type_and_date_and_is_ok_an; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_commentaries_on_commentariable_type_and_date_and_is_ok_an ON commentaries USING btree (commentariable_type, date, is_ok, is_news);


--
-- Name: index_commentaries_on_status; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_commentaries_on_status ON commentaries USING btree (status);


--
-- Name: index_comments_on_commentable_id_and_commentable_type; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_id_and_commentable_type ON comments USING btree (commentable_id, commentable_type);


--
-- Name: index_comments_on_commentable_type; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_type ON comments USING btree (commentable_type);


--
-- Name: index_comments_on_created_at_and_commentable_type; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_created_at_and_commentable_type ON comments USING btree (created_at, commentable_type);


--
-- Name: index_comments_on_ok; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_ok ON comments USING btree (ok);


--
-- Name: index_comments_on_parent_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_parent_id ON comments USING btree (parent_id);


--
-- Name: index_comments_on_root_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_root_id ON comments USING btree (root_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_congress_sessions_on_date; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_congress_sessions_on_date ON congress_sessions USING btree (date);


--
-- Name: index_crp_contrib_individual_to_candidate_on_crp_interest_group; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_individual_to_candidate_on_crp_interest_group ON crp_contrib_individual_to_candidate USING btree (crp_interest_group_osid);


--
-- Name: index_crp_contrib_individual_to_candidate_on_recipient_osid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_individual_to_candidate_on_recipient_osid ON crp_contrib_individual_to_candidate USING btree (recipient_osid);


--
-- Name: index_crp_contrib_pac_to_candidate_on_crp_interest_group_osid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_pac_to_candidate_on_crp_interest_group_osid ON crp_contrib_pac_to_candidate USING btree (crp_interest_group_osid);


--
-- Name: index_crp_contrib_pac_to_candidate_on_recipient_osid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_pac_to_candidate_on_recipient_osid ON crp_contrib_pac_to_candidate USING btree (recipient_osid);


--
-- Name: index_crp_contrib_pac_to_pac_on_filer_osid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_pac_to_pac_on_filer_osid ON crp_contrib_pac_to_pac USING btree (filer_osid);


--
-- Name: index_crp_contrib_pac_to_pac_on_recipient_crp_interest_group_os; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_contrib_pac_to_pac_on_recipient_crp_interest_group_os ON crp_contrib_pac_to_pac USING btree (recipient_crp_interest_group_osid);


--
-- Name: index_crp_interest_groups_on_osid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_crp_interest_groups_on_osid ON crp_interest_groups USING btree (osid);


--
-- Name: index_facebook_templates_on_template_name; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE UNIQUE INDEX index_facebook_templates_on_template_name ON facebook_templates USING btree (template_name);


--
-- Name: index_fundraisers_on_person_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_fundraisers_on_person_id ON fundraisers USING btree (person_id);


--
-- Name: index_group_members_on_group_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_group_members_on_group_id ON group_members USING btree (group_id);


--
-- Name: index_group_members_on_user_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_group_members_on_user_id ON group_members USING btree (user_id);


--
-- Name: index_political_notebooks_on_group_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_political_notebooks_on_group_id ON political_notebooks USING btree (group_id);


--
-- Name: index_privacy_options_on_user_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_privacy_options_on_user_id ON privacy_options USING btree (user_id);


--
-- Name: index_roles_on_person_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_roles_on_person_id ON roles USING btree (person_id);


--
-- Name: index_roll_calls_on_where_and_number_and_date; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_roll_calls_on_where_and_number_and_date ON roll_calls USING btree ("where", number, date);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_users_on_facebook_uid; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_users_on_facebook_uid ON users USING btree (facebook_uid);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_zip_four; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_users_on_zip_four ON users USING btree (zip_four);


--
-- Name: index_users_on_zipcode; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_users_on_zipcode ON users USING btree (zipcode);


--
-- Name: index_videos_on_bill_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_videos_on_bill_id ON videos USING btree (bill_id);


--
-- Name: index_videos_on_embed; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_videos_on_embed ON videos USING btree (embed);


--
-- Name: index_videos_on_person_id; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_videos_on_person_id ON videos USING btree (person_id);


--
-- Name: index_videos_on_url; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_videos_on_url ON videos USING btree (url);


--
-- Name: index_zipcode_districts_on_state; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX index_zipcode_districts_on_state ON zipcode_districts USING btree (state);


--
-- Name: panel_referrers_panel_type_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX panel_referrers_panel_type_index ON panel_referrers USING btree (panel_type);


--
-- Name: panel_referrers_referrer_url_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX panel_referrers_referrer_url_index ON panel_referrers USING btree (referrer_url);


--
-- Name: people_cycle_contributions_person_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX people_cycle_contributions_person_id_index ON people_cycle_contributions USING btree (person_id);


--
-- Name: people_firstname_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX people_firstname_index ON people USING btree (firstname, lastname);


--
-- Name: people_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX people_fti_names_index ON people USING gist (fti_names);


--
-- Name: roll_call_votes_person_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX roll_call_votes_person_id_index ON roll_call_votes USING btree (person_id);


--
-- Name: roll_call_votes_roll_call_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX roll_call_votes_roll_call_id_index ON roll_call_votes USING btree (roll_call_id);


--
-- Name: sidebarable_poly_idx; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX sidebarable_poly_idx ON sidebar_boxes USING btree (sidebarable_id, sidebarable_type);


--
-- Name: site_texts_text_type_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX site_texts_text_type_index ON site_texts USING btree (text_type);


--
-- Name: subject_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX subject_fti_names_index ON subjects USING gist (fti_names);


--
-- Name: subject_relations_subject_id_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX subject_relations_subject_id_index ON subject_relations USING btree (subject_id, related_subject_id, relation_count);


--
-- Name: subjects_term_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX subjects_term_index ON subjects USING btree (term);


--
-- Name: u_email; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE UNIQUE INDEX u_email ON users USING btree (email);


--
-- Name: u_users; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE UNIQUE INDEX u_users ON users USING btree (login);


--
-- Name: upcoming_bill_fti_names_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX upcoming_bill_fti_names_index ON upcoming_bills USING gist (fti_names);


--
-- Name: users_lower_email_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX users_lower_email_index ON users USING btree (lower((email)::text));


--
-- Name: users_lower_login_index; Type: INDEX; Schema: public;; Tablespace: 
--

CREATE INDEX users_lower_login_index ON users USING btree (lower((login)::text));


--
-- Name: aggregate_bill_votes_trigger; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER aggregate_bill_votes_trigger
    AFTER INSERT ON bill_votes
    FOR EACH ROW
    EXECUTE PROCEDURE aggregate_increment();


--
-- Name: aggregate_bookmark_trigger; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER aggregate_bookmark_trigger
    AFTER INSERT ON bookmarks
    FOR EACH ROW
    EXECUTE PROCEDURE aggregate_increment();


--
-- Name: aggregate_comment_trigger; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER aggregate_comment_trigger
    AFTER INSERT ON comments
    FOR EACH ROW
    EXECUTE PROCEDURE aggregate_increment();


--
-- Name: aggregate_commentaries_trigger; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER aggregate_commentaries_trigger
    AFTER INSERT ON commentaries
    FOR EACH ROW
    EXECUTE PROCEDURE aggregate_increment();


--
-- Name: article_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER article_tsvectorupdate
    BEFORE INSERT OR UPDATE ON articles
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'article');


--
-- Name: bill_titles_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER bill_titles_tsvectorupdate
    BEFORE INSERT OR UPDATE ON bill_titles
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_titles', 'title');


--
-- Name: bill_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER bill_tsvectorupdate
    BEFORE INSERT OR UPDATE ON bill_fulltext
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'fulltext');


--
-- Name: commentary_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER commentary_tsvectorupdate
    BEFORE INSERT OR UPDATE ON commentaries
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'title', 'excerpt', 'source');


--
-- Name: comments_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER comments_tsvectorupdate
    BEFORE INSERT ON comments
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'comment');


--
-- Name: committee_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER committee_tsvectorupdate
    BEFORE INSERT OR UPDATE ON committees
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'name', 'subcommittee_name');


--
-- Name: people_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER people_tsvectorupdate
    BEFORE INSERT OR UPDATE ON people
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'name', 'firstname', 'lastname', 'nickname', 'unaccented_name');


--
-- Name: subject_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER subject_tsvectorupdate
    BEFORE INSERT OR UPDATE ON subjects
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'term');


--
-- Name: upcoming_bill_tsvectorupdate; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER upcoming_bill_tsvectorupdate
    BEFORE INSERT OR UPDATE ON upcoming_bills
    FOR EACH ROW
    EXECUTE PROCEDURE tsearch2('fti_names', 'title', 'summary');


--
-- Name: public; Type: ACL; Schema: -;
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

