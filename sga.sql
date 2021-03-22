--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Informations about sga usage in the database
-- Date:   08.2013
--
-- http://docs.oracle.com/cd/B28359_01/server.111/b28320/dynviews_2058.htm#REFRN30463
--==============================================================================
set linesize 130 pagesize 300 

-- sga infos

ttitle left  "SGA Pools" skip 2

show sga

ttitle left "Dynamic SGA Componentes" skip 2

column component             format a20      heading "Component"  WORD_WRAPPED
column current_size          format 99G999D99  heading "Cur|Size MB"
column min_size              format 99G999D99  heading "Min|Size MB"
column max_size              format 99G999D99  heading "Max|Size MB"
column user_specified_size   format 99G999D99  heading "UserDef|Size MB"
column oper_count            format 9999999    heading "OP|count"
column last_oper_type        format a12        heading "OP|type"
column last_oper_mode        format a15        heading "OP|mode"
column last_oper_time        format a18        heading "OP|time"
column granule_size          format 999999     heading "Granule|size KB"
 
select component
	,  round(current_size/1024/1024,2) as current_size
	,  round(min_size/1024/1024,2) as min_size
	,  round(max_size/1024/1024,2) as  max_size
	,  round(user_specified_size/1024/1024,2) as user_specified_size
	,  oper_count
	,  nvl(last_oper_type,'-') as last_oper_type
	,  nvl(last_oper_mode,'-') as last_oper_mode
	,  nvl(to_char(last_oper_time,'dd.mm.yyyy hh24:mi'),'never') as last_oper_time
	,  round(granule_size/1024,2) as granule_size
 from v$memory_dynamic_components
order by 1 desc
 /

ttitle left  "SGA Advisory" skip 2

select * from v$sga_target_advice 
 order by 1
/


ttitle left  "Library Cache hits" skip 2

select sum(pins) "hits"
     , sum(reloads) "misses"
	 , round((sum(pins)/(sum(reloads)+sum(pins)))*100, 2) "hit ratio, %"
from v$librarycache
/


ttitle left  "Buffer Cache hit statistic" skip 2

select round((1-(pr.value/(bg.value+cg.value)))*100,2) "Buffer Cache Hit Ratio"
 from  v$sysstat pr
     , v$sysstat bg
	 , v$sysstat cg
where pr.name='physical reads'
  and bg.name='db block gets'
  and cg.name='consistent gets'
/

ttitle off