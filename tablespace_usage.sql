--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the object count and size of a tablespace
-- Date:   Januar 2015
--==============================================================================

set verify off
set linesize 130 pagesize 300 


define TABLESPACE = "&1"


prompt
prompt Parameter 1 = Tablespace Name  => '&TABLESPACE' 
prompt


ttitle left  "Space Usage overview for this tablespace &TABLESPACE" skip 2

column OWNER format a25  

--user summary
--break on owner SKIP 1
--COMPUTE SUM OF size_GB ON owner

column dummy noprint;
compute sum of size_gb on dummy;
break on dummy;


select  null dummy
     , owner
     , obj_type
	 , obj_count 
	 , sum(size_GB) as size_GB
 from (
	select count(*) as obj_count
	    , o.object_type as obj_type
		 , o.owner  
		 ,round( sum(s.bytes) /1024/1024/1024 , 3) as size_GB
	  from dba_objects o
	     , dba_segments s
	 where s.owner=o.owner
	   and s.segment_name =o.object_name(+)
		and s.TABLESPACE_NAME= upper('&TABLESPACE.')
		--and o.object_name like '%TEMP%'
	 group by o.object_type,o.owner
 ) 
where obj_type in ('TABLE','INDEX','LOB')
--GROUP BY rollup (owner,obj_type,obj_count)
group by owner,obj_type,obj_count
order by owner,obj_type
/

ttitle left  "Space Usage overview for this tablespace &TABLESPACE - the 25 top objects" skip 2

select * from (
	select  object_name
			, object_type
			, owner  	
			, size_GB
			, rank() OVER (ORDER BY size_GB DESC) AS rang
	from (
		select  o.object_name
				, o.object_type
				, o.owner  	
				, round( (s.bytes) /1024/1024/1024 , 3) as size_GB
			  from dba_objects o
				  , dba_segments s
			 where s.owner=o.owner
				and s.segment_name =o.object_name
				and s.TABLESPACE_NAME= upper('&TABLESPACE.')			
       --order by s.bytes			
		)
) 
--where rownum < 25
where rang < 25
/
	 
ttitle off

clear break
