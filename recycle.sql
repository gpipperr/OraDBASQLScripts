--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the content summary of the dba recyclebin
-- Date:   02.2014
--==============================================================================
set linesize 130 pagesize 300 

set verify off

column owner format a15 heading "Owner"
column TYPE  format a12 heading "Obj|type"

column max_CREATETIME format a14 heading "Min|Create"
column min_CREATETIME format a14 heading "Max|Create"
column min_DROPTIME   format a14 heading "Min Age|Drop"
column max_DROPTIME   format a16 heading "Max Age|Drop"
column SPACE_GB       format 999G999D99 heading "Space|GB"

--
--fix use DB Block size!!
--
--define BLOCK_SIZE=8192
define BLOCK_SIZE=16384

--
show parameter recyclebin


---
column DUMMY NOPRINT;
COMPUTE SUM OF SPACE_GB ON DUMMY;
BREAK ON DUMMY;


select null dummy
      , owner
	  , count(*) as anzahl
	  , TYPE
	  , substr(min(CREATETIME),1,13)  as min_CREATETIME
	  , substr(max(CREATETIME),1,13)  as max_CREATETIME
	  , substr(min(DROPTIME),1,13)    as min_DROPTIME
	  , substr(max(DROPTIME),1,16)    as max_DROPTIME
	  , round(((sum(space)*&&BLOCK_SIZE)/1024/1024/1024),2) as SPACE_GB
 from DBA_RECYCLEBIN
group by owner
       , type
order by 1,2		 
/		 

prompt .....
prompt ..... -- to clean all:  PURGE DBA_RECYCLEBIN ( as sys user!)
prompt ..... -- to clean your bin : PURGE RECYCLEBIN; 
prompt .....

set verify on