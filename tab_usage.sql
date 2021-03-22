--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: check if the table is used in the last time - parameter - Owner, Table name
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME  = &1
define TABLE_NAME = &2 

prompt
prompt Parameter 1 = Owner Name => &&USER_NAME.
prompt Parameter 2 = Tab Name   => &&TABLE_NAME.
prompt

ttitle center "Check if a column of the Table was in use in SQL Queries" SKIP 2

column  owner        format a14 
column  object_name  format a24
column  column_name  format a18

column equality_preds    format 99G999   heading "equ"
column equijoin_preds    format 99G999   heading "Jequ"
column nonequijoin_preds format 99G999   heading "Jnoe"
column range_preds       format 99G999   heading "ran"
column like_preds        format 99G999   heading "lik"
column null_preds        format 99G999   heading "nul"
column last_collect      format a18     heading "last Usage |collected"


select  o.owner
      , o.object_name
      , c.name as column_name
      , u.equality_preds
      , u.range_preds
      , u.like_preds
      , u.null_preds
      , u.equijoin_preds
      , u.nonequijoin_preds
	  , to_char(u.TIMESTAMP,'dd.mm.yyyy hh24:mi') as last_collect
  from  sys.col_usage$ u
      , dba_objects    o
      , sys.col$       c
 where u.obj# = o.OBJECT_ID
   and u.obj# = c.obj#
   and u.intcol# = c.col#
   and upper(o.owner) like upper('&&USER_NAME.')
   and upper(o.object_name) like upper('&&TABLE_NAME.')
 order by o.owner
         ,o.object_name
         ,c.name
/  

ttitle off

ttitle center "Check if in the SQL cache" SKIP 2

@sql_find &&TABLE_NAME.

ttitle off

