-- =================================================
-- GPI - Gunther Pippèrr
-- Desc: check the result of index monitoring   
-- =================================================
-- source see https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:12840327558363
--==============================================================================
column SPOOL_NAME_COL new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_col_usage.html'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/


column  owner       format a15 heading "Owner"
column  index_name  format a32 heading "Index|Name"
column  table_name  format a20 heading "Table|Name"
column  USED         format a3  heading "In|Use"
column  MONITORING  format a3  heading "Mon|On"
column  start_monitoring format a20 heading "Start|Monitoring"
column  end_monitoring   format a20 heading "End|Monitoring"


spool &&SPOOL_NAME

set markup html on

set verify off
set linesize 130 pagesize 2000 

select to_char (sysdate, 'dd.mm.yyyy hh24:mi') as anlayse_date from dual
/

select u.name owner
       ,  t.name TABLE_NAME
       ,  io.name index_name
       ,  decode (bitand (i.flags, 65536), 0, 'NO', 'YES') MONITORING
       ,  decode (bitand (ou.flags, 1), 0, 'NO', 'YES') USED
       ,  ou.start_monitoring
       ,  ou.end_monitoring
    from sys.user$ u
       ,  sys.obj$ io
       ,  sys.obj$ t
       ,  sys.ind$ i
       ,  sys.object_usage ou
   where  i.obj# = ou.obj#
     and io.obj# = ou.obj#
     and t.obj# = i.bo#
     and u.user# = io.owner#
order by t.name, io.name
/

set markup html off
spool off
ttitle off

-- works only in a ms windows enviroment
-- autostart of the result in a browser window
host &&SPOOL_NAME
