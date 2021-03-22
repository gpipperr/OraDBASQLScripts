--==============================================================================
-- GPI -  Gunther Pippèrr 
-- Desc: get Information’s about the DB latch usage
--==============================================================================
set linesize 130 pagesize 300 

column name format a32
column gets format 999G999G999
column ratio_miss format 90D99
column spin_gets format 999G999G999

select a.name
     , a.gets gets
	 , a.misses
	 , ROUND(a.misses * 100 / DECODE(a.gets, 0, 1, a.gets), 2) ratio_miss
	 , a.spin_gets
  from v$latch a
 where a.misses <> 0
 order by 2 desc
 /
