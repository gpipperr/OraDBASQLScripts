--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the my optimizer settings
--
--==============================================================================
set linesize 130 pagesize 300 

column name        format a40 heading  "OptFeature|Name" 
column sql_feature format a20 heading  "SQL|Feature"
column isdefault   format a4  heading  "DEF|AULT"
column value       format a20 heading  "Value"
column sid         format 9999 heading "My|SID"

select o.name
	, o.sql_feature
	, o.isdefault
	, o.value
 from gv$ses_optimizer_env o
    , gv$session s
where s.sid = o.sid
  and s.inst_id=o.inst_id
  and s.username= user
  and s.sid=sys_context('userenv','SID')
order by o.name
/
