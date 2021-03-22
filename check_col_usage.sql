--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report column usage for SQL queries and indexes
--
-- HTML Report - Table column used in SQL Statements but not indexed and 
-- all indexes with more than one column to check for duplicate indexing
--
--==============================================================================

define OWNER    = '&1' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt
 
variable own varchar2(20);
exec :own := upper('&&OWNER');


col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_col_usage.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

spool &&SPOOL_NAME

set markup html on

ttitle center "Columns usesd in SQL Queries but not indexed" SKIP 2

set verify off
SET linesize 130 pagesize 2000 

column  owner        format a20
column  object_name  format a30
column  column_name  format a25

column equality_preds    format 99999   heading "equ"
column equijoin_preds    format 99999   heading "Jequ"
column nonequijoin_preds format 99999   heading "Jnoe"
column range_preds       format 99999   heading "ran"
column like_preds        format 99999   heading "lik"
column null_preds        format 99999   heading "nul"

select o.owner
      ,o.object_name
      ,c.name as column_name
      ,u.equality_preds
      ,u.range_preds
      ,u.like_preds
      ,u.null_preds
      ,u.equijoin_preds
      ,u.nonequijoin_preds
  from sys.col_usage$ u
      ,dba_objects    o
      ,sys.col$       c
 where u.obj# = o.OBJECT_ID
   and u.obj# = c.obj#
   and u.intcol# = c.col#
   and o.owner like :own
   and not exists (select 1
          from dba_ind_columns i
         where i.table_owner = o.owner
           and i.table_name = o.object_name
           and i.column_name = c.name)
 order by o.owner
         ,o.object_name
         ,c.name
/  


ttitle center "Index with more then one Columns" SKIP 2

SET linesize 130 pagesize 2000 

column   index_owner format a25
column   index_name  format a25
column   table_name  format a25
column   column_name format a25
column  pos1      format a25
column  pos2        format a25 
column  pos3        format a25
column  pos4        format a25
column  pos5        format a25
column  pos6        format a25
column  pos7        format a25
column  pos8        format a25
column  pos9        format a25
      
select *
  from (select *
          from (select index_owner
                      ,table_name
                      ,index_name
                      ,column_name
                      ,column_position
                  from dba_ind_columns
                 where index_owner like :own
                 order by index_owner
                         ,table_name) pivot(min(column_name) for column_position in('1' as pos1, '2' as pos2,
                                                                                    '3' as pos3, '4' as pos4, '5' as pos5,
                                                                                    '6' as pos6, '7' as pos7, '8' as pos8,
                                                                                    '9' as pos9)))
 where pos2 is not null
/
 
set markup html off
spool off
ttitle off

-- works only in a ms windows enviroment
-- autostart of the result in a browser window
host &&SPOOL_NAME
