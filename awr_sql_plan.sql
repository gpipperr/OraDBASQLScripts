--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   get the sql execution plan for this sql id from the AWR Repository
--         You need the Tuning Pack Licence to use the AWR! 
--		   Only 11g SQL Syntax!
-- Date:   September 2013
--
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 0 
set verify off

define SQL_ID = &1
 
ttitle left  "SQL Plan from AWR ID:  &SQL_ID." skip 2

--11g
select * from   TABLE(dbms_xplan.display_awr(sql_id=> '&SQL_ID.', format => 'TYPICAL'));

--10g
--select * from   TABLE(dbms_xplan.display_awr('&SQL_ID.')); 

ttitle off
