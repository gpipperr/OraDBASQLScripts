-- ===================================================================
-- GPI - Gunther Pippèrr
-- get the process of a session marked for killed
-- ===================================================================
--
-- see How To Find The Process Identifier (pid, spid) After The Corresponding Session Is Killed? (Doc ID 387077.1)
-- ===================================================================

set verify off
set linesize 130 pagesize 300 

ttitle left "Processes without entries in the v$session" skip 2

column process_id format a8     heading "Process|ID"
column inst_id    format 99     heading "Inst|ID"
column username   format a8     heading "DB User|name"
column osusername   format a8   heading "OS User|name"
column pname       format a8    heading "Process|name"

select --p.inst_id  
       to_char(p.spid) as process_id
	 , p.username as osusername
	 , p.pname			
	 , p.program
from v$process p
 where p.program!= 'PSEUDO' 
   and p.addr not in (select gv.paddr from v$session gv)
   and p.addr not in (select bg.paddr from v$bgprocess bg)
   and p.addr not in (select ss.paddr from v$shared_server ss)
   --order by p.inst_id 
/	 
	 
-- new column creator_addr in v$session!

ttitle left  "get the prozess of a killed session with the help of the creator_addr" skip 2

select --p.inst_id  
      to_char(p.spid) as process_id
	 , p.username as osusername
	 , p.pname			
	 , p.program
from v$process p
 where p.addr in (select gv.creator_addr from v$session gv where status in ('KILLED') )
/	

ttitle off

