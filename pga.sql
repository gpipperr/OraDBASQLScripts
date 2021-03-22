--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:    Informations about the pga usage in the database
-- Date:   08.2013
--
--==============================================================================
set linesize 130 pagesize 300 

-- sga infos

ttitle left  "PGA DB Parameter" skip 2

show parameter pga_aggregate_target

ttitle off

show parameter workarea_size_policy
prompt
prompt ... must be "auto" for the use of the pga feature

ttitle left  "" skip 2

ttitle left  "Sorts in Memory percentage" skip 2
select round((mem.value/(mem.value+dsk.value))*100,2) "Sorts in Mem"
  from v$sysstat mem, v$sysstat dsk
where mem.name='sorts (memory)'
  and dsk.name='sorts (disk)'
/

ttitle left  "PGA Usage" skip 2

select p.inst_id 
	 , count(*) sess_cnt
     , s.username
	 , round(sum(pga_used_mem/(1024*1024)),0) pga_used_mem_mb
	 , round(sum(pga_alloc_mem/(1024*1024)),0) pga_alloc_mem_mb
	 , round(sum(pga_freeable_mem/(1024*1024)),0) pga_freeable_mem_mb
	 , round(sum(pga_max_mem/(1024*1024)),0) pga_max_mem_mb
 from gv$process p
    , gv$session s 
where p.addr=s.paddr 
  and p.inst_id = s.inst_id
  and s.username is not null
  and s.username not in ('SYS')
group by s.username
       , p.inst_id 
order by pga_alloc_mem_mb
       , pga_used_mem_mb
/

column name     format a38
column inst_id  format 99
column value    format 999G999G999G999G999 heading "Values"

ttitle left  "PGA Statistic" skip 2
select   inst_id 
       , name
       , value 
	   , unit
  from gv$pgastat
order by inst_id,name
/

ttitle left  "PGA Advisory" skip 2

column c1 heading 'PGA Target(M)'
column c2 heading 'Estimated|Cache Hit %'
column c3 heading 'Estimated|Over-Alloc.'

select pga_target_for_estimate/(1024*1024) c1
	,  estd_pga_cache_hit_percentage c2
	,  estd_overalloc_count c3
 from v$pga_target_advice
/

ttitle off