--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get a overview over the free and used space for a tablespace 
--       parameter name of the tablespace
--==============================================================================
-- http://oraculix.wordpress.com/2010/10/03/ora-01652-und-fragmentierte-tablespaces/
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define TABLESPACE_NAME = '&1' 

prompt
prompt Parameter 1 = Tablespace Name => &&TABLESPACE_NAME.
prompt

column file_id               format  9999         heading "File|Id"
column free_space_parts      format  999G999G999  heading "Free|Parts" 
column free_bytes_total      format  999G999D99   heading "Free Total|MB's"   
column free_blocks_total     format  999G999G999  heading "Free Total|Blocks" 
column max_free_bytes_in_one format  999G999D99   heading "Largest|MB's" 
column max_free_blks_in_one  format  999G999G999  heading "Largest|Blocks" 

select  file_id,
        count(*)    free_space_parts
       ,round(sum(bytes)/1024/1024,2)  free_bytes_total
       ,sum(blocks) free_blocks_total
       ,round(max(bytes)/1024/1024,2)  max_free_bytes_in_one
       ,max(blocks) max_free_blks_in_one
 from sys.dba_free_space
where upper(tablespace_name)=upper('&&tablespace_name')		 
group by tablespace_name
     , file_id
order by file_id	  
/

prompt
prompt existing storage distriubtion in the tablespace
prompt

select sizes
   , count(distinct segment_name) segs
	, sum(blocks) blks
 from (select segment_name
              , case
                 when blocks < 128 then 'small'
                 when blocks between 128 and 1023 then 'mittel'
                 else 'large'
                end as sizes
				 , blocks
          from dba_extents
         where tablespace_name = upper('&&tablespace_name')
			)
group by sizes
order by blks desc
/

prompt
prompt Extented distribution over the tables
prompt

select segment_name
     , bytes/1024  as kb
	  , count(*)
  from dba_extents
 where tablespace_name=upper('&&tablespace_name')
 group by segment_name,bytes
 order by 1
 /

