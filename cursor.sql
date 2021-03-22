--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Informations about cursor usage in the database
-- Date:   08.2013
--==============================================================================

set linesize 130 pagesize 300 

column user_name format a25

ttitle left  "Open Cursor used summary" skip 2

select inst_id
	 , user_name
     , count(*)
 from gv$open_cursor 
where  user_name is not null -- and user_name not in ( 'SYS' ) 
group by rollup (inst_id,user_name)
/

ttitle left  "Open Cursor used by session" skip 2
select inst_id
     , sid	
	 , user_name	
     , count(*)
 from gv$open_cursor 
where user_name is not null -- and user_name not in ( 'SYS' ) 
group by inst_id,user_name,sid
order by 4,1,3
/

column name  format a30 heading "Statistic|Name"
column value format 999G999G999G999 heading "Statistic|value"


ttitle left  "Open Cursor used by session over the statistic" skip 2

select  a.value
      , s.username
	  , s.sid
	  , s.serial# 
from v$sesstat a
   , v$statname b
	, v$session s 
where a.statistic# = b.statistic#  
  and s.sid=a.sid 
  and b.name = 'opened cursors current'
  and  s.username is not null
 /


ttitle left  "Open Cursor Statistic " skip 2

column execute_count         format 999G999G999G999G999 heading "SQL Execution"
column parse_count           format 999G999G999G999G999 heading "Parse Count"
column cursor_hits           format 999G999G999G999G999 heading "Cursor Hits"
column hit_percentage_parse  format 99D990  heading "Parse| % Total"
column hit_percentage_cursor format 99D990  heading "Cursor Cache | % Total"

select  inst_id
	  , execute_count
	  , parse_count	
	  , round(parse_count/(execute_count/100),3) as hit_percentage_parse
	  , cursor_hits
	  , round(cursor_hits/(execute_count/100),3) as hit_percentage_cursor
  from ( select name
			   , value
			   , inst_id
		 from gv$sysstat
		where name in ('session cursor cache hits','parse count (total)','execute count')		
		)
		pivot ( 
			   max (value)
				 FOR name
				 IN  (  'session cursor cache hits' AS cursor_hits
					  , 'parse count (total)' as parse_count
					  , 'execute count' as execute_count
				)
		)
/

prompt ... 11g Syntax if you hid an error on 10g!
prompt ... if Cursor Cache % Total is a relatively low percentage
prompt ... you should increate the DB Parameter session_cached_cursors

ttitle left  "Cursor Settings init.ora " skip 2
show parameter cursor


ttitle left  "Session cached Cursor Usage " skip 2
-- 
-- see also 
-- SCRIPT - to Set the 'SESSION_CACHED_CURSORS' and 'OPEN_CURSORS' Parameters Based on Usage (Doc ID 208857.1)
--

select a.inst_id 
	 , 'session_cached_cursors'  parameter
     ,  lpad(value, 5)  value
	 ,  decode(value, 0, '  n/a', to_char(100 * used / value, '990') || '%')  usage
from
  ( select   max(s.value)  used , inst_id
      from  v$statname  n
         ,  gv$sesstat  s
     where  n.name = 'session cursor cache count' and  s.statistic# = n.statistic#
	  group by inst_id
  ) a,
  ( select value,inst_id
      from gv$parameter
     where name = 'session_cached_cursors'
  ) b
  where a.inst_id=b.inst_id
union all
select c.inst_id
     , 'open_cursors'
	 , lpad(value, 5)
     , to_char(100 * used / value,  '990') || '%'
from
  ( select s.inst_id , max((s.value)) used
	  from   v$statname  n
		   , gv$sesstat  s
      where n.name in ('opened cursors current') 
	    and s.statistic# = n.statistic#
    group by s.inst_id
  ) c,
  ( select  value,inst_id
      from  gv$parameter
    where   name = 'open_cursors'
  ) d
  where c.inst_id=d.inst_id
order by 1,2  
/
ttitle off

prompt ... if usage percentage is a near 100%
prompt ... you should increate the DB Parameter session_cached_cursors 