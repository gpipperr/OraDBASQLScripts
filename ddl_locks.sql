--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: check for DDL Locks
--==============================================================================

set verify  off
set linesize 130 pagesize 4000 

define OWNER    = '&1' 
define OBJECTNAME    = '&2' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = Object Name => &&OBJECTNAME.
prompt


column SESSION_ID     format a12 heading "Session|Serial" 
column OWNER          format a20 
column NAME           format a22 heading "Object|Name"
column TYPE           format a22
column MODE_HELD      format a10
column MODE_REQUESTED format a10
column username   format a18

select  dl.SESSION_ID||','||v.SERIAL# as  SESSION_ID   
      , v.username
      , dl.OWNER||'.'||dl.NAME  as name        
      , dl.TYPE          
      , dl.MODE_HELD     
      , dl.MODE_REQUESTED
 from DBA_DDL_LOCKS dl
    , v$session v
where OWNER like upper('&&OWNER.%') 
  and NAME like upper('&&OBJECTNAME.%') 
  and v.SID=dl.SESSION_ID
order by v.username
/


-- shows only tables?
--select gv.* , do.object_name
--   from GV$LOCKED_OBJECT gv
--	   , dba_objects do 
--where gv.OBJECT_ID=do.OBJECT_ID
--and do.object_name like upper('&&OBJECTNAME.%') 
--/

column NAME           format a30

select en.name
     , se.TOTAL_WAITS
 from v$system_event se
    , v$event_name   en
where en.name in ('latch free','library cache load lock','library cache lock','library cache pin')
 and  se.EVENT_ID=en.EVENT_ID
 group by en.name
        , se.TOTAL_WAITS
/



