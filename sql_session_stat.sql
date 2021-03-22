--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get statistics from running session for this SQL
-- Work in progress
--==============================================================================
set linesize 130 pagesize 300 

define SQL_STATEMENT = &1

prompt
prompt Parameter 1 = SQL_STATEMENT    => &&SQL_STATEMENT.
prompt

ttitle  "Report sessions statistic for this SQL &&SQL_STATEMENT."  skip 2

column client_info  format a30
column MODULE       format a20
column username     format a10 heading "User|name"
column program      format a20
column state        format a20
column event        format a15
column last_sql     format a20
column sec          format 99999 heading "Wait|sec"
column inst         format 9     heading "Inst"
column ss           format a10 heading "SID:Ser#"
column name         format a30

break on ss

select inst
       ,  ss
       ,  username
       ,  name
       ,  value
       ,  round (  (ratio_to_report (sum (value)) over (partition by ss))* 100,  3) as prozent
    from (select  /* gpi script lib session_stat.sql */
                  sw.inst_id as inst
               ,  s.sid || ',' || s.serial# as ss
               --, s.client_info
               --, s.MODULE
               ,  s.username
               --, s.program
               ,  sn.name
               ,  sw.value
            from gv$sesstat sw, v$statname sn, gv$session s
           where sw.STATISTIC# = sn.STATISTIC#
             and sn.NAME in ('table fetch continued row', 'table fetch by rowid')
             --
             and sw.inst_id = s.inst_id
             and sw.sid = s.sid
             --
             and s.sql_id = '&&SQL_STATEMENT.')
group by inst
       ,  ss
       ,  username
       ,  name
       ,  value
order by inst, ss
/

clear break

ttitle off

