--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the name of a wait statistic
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define SYSSTAT_NAME = &1

prompt
prompt Parameter 1 = SYSSTAT_NAME     => &&SYSSTAT_NAME.
prompt


------------------------------------------------------------
ttitle 'Search after all waits statistics with this name &&SYSSTAT_NAME.' skip 2


select statistic#
	  , name
	  , class
 from v$statname 
where name like '&&SYSSTAT_NAME.%'
order by 2
/


ttitle off
