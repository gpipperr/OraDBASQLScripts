--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the tablespaces of all the users
-- Date:   November 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

column tablespace_name format a20 heading "Tablespace|Name"
column segment_type    format a20 heading "Segment|Type"
column count_          format 99999 heading "Count|Objects"
column space_usage     format 999G999G999D99 heading "Space|Usage"

BREAK ON owner

select   owner
      ,  tablespace_name
      , segment_type
	  , '::' as "|"
	  , count(*) as count_ 
	  , round(sum(bytes)/1024/1024,2) as space_usage
 from dba_segments 
group by tablespace_name,segment_type,owner
order by owner,tablespace_name,segment_type
/
