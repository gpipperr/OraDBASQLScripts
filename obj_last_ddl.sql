-- ==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  get the last DDL Changes from a user 
-- ==============================================================================
set verify  off
set linesize 130 pagesize 300 

define OWNER       = '&1' 
define OBJECT_TYPE = '%' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Object Type => &&OBJECT_TYPE.
prompt

column OBJECT_NAME     format a30
column OBJECT_TYPE     format a16
column CREATED         format a18
column LAST_DDL_TIME   format a18

ttitle "show the last 30 DDL's on this Schema"  skip 2

select * from (
	select o.OBJECT_NAME
		  ,o.OBJECT_TYPE
		  ,o.CREATED
		  ,o.LAST_DDL_TIME
	  from dba_objects o
	 where o.owner like upper( '&&OWNER.' )
		and object_type like upper('&&OBJECT_TYPE.')
	order by 4 desc
)
where rownum < 100
/

ttitle off
