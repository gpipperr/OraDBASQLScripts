-- ==============================================================================
-- GPI - Gunther Pippèrr
-- show all created sql profiles in this database
-- Must be run with dba privileges 
-- see 
-- ==============================================================================
--
-- desc dba_sql_profiles
-- ------------------------------------
-- NAME  			NOT NULL VARCHAR2(30)
-- CATEGORY 		NOT NULL VARCHAR2(30)
-- SIGNATURE 		NOT NULL NUMBER
-- SQL_TEXT 		NOT NULL CLOB
-- CREATED 		NOT NULL TIMESTAMP(6)
-- LAST_MODIFIED  	      TIMESTAMP(6)
-- DESCRIPTION      	   VARCHAR2(500)
-- TYPE          			VARCHAR2(7)
-- STATUS          			VARCHAR2(8)
-- FORCE_MATCHING         VARCHAR2(3)
-- TASK_ID          		NUMBER
-- TASK_EXEC_NAME         VARCHAR2(30)
-- TASK_OBJ_ID          	NUMBER
-- TASK_FND_ID          	NUMBER
-- TASK_REC_ID          	NUMBER
--
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column name        format a30 heading "Profile|Name"
column category    format a12 heading "Category|Name"
column description format a12 heading "Description"
column type        format a6  heading "Type"
column status      format a7  heading "Status"
column force_matching  format a3  heading "For|Mch"
column sql_text        format a30 word_wrapped

set long 64000

ttitle "All Profiles in the database" skip 2

  select name
       ,  category
       -- , signature
       ,  substr (sql_text, 1, 100) as sql_text
       -- , to_char(created,'dd.mm.RR hh24:mi')             as created
       ,  to_char (last_modified, 'dd.mm.RR hh24:mi') as created
       ,  description
       ,  type
       ,  status
       ,  force_matching
    --, TASK_ID
    -- ,  TASK_EXEC_NAME
    -- ,  TASK_OBJ_ID
    -- ,  TASK_FND_ID
    -- ,  TASK_REC_ID
    from dba_sql_profiles
order by last_modified desc, name
/


ttitle "check the SQL Profiles in use" skip 2

select vs.inst_id
     ,  vs.sql_id
     ,  pf.name
     --, substr(pf.sql_text,1,100) as sql_text
     ,  to_char (last_modified, 'dd.mm.RR hh24:mi') as created
  from gv$sql vs, dba_sql_profiles pf
 where     pf.name = vs.sql_profile
       and SQL_PROFILE is not null
--order by substr(to_char(pf.sql_text),1,100)
/

prompt ...
prompt to delete a profile use exec dbms_sqltune.drop_sql_profile(  name  => 'SYS_SQLPROF_xxx');
prompt to rename a profile use exec dbms_sqltune.alter_sql_profile(  name => 'SYS_SQLPROF_xxx', attribute_name => 'NAME', VALUE => 'GPI_BUG_1078' );
prompt ...

ttitle off

