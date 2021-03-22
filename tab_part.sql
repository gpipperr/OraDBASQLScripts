--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc.:   show the partitions of a table
-- Parameter 1: Name of the User
-- Parameter 2: Name of the Table
--
-- Must be run with dba privileges
-- 
--
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.
prompt

--------------------
-- dba_partition_columns
--------------------

column table_owner        format a12  heading "Owner"
column partition_name     format a30  heading "Part|Name" 
column partition_position format 999  heading "Posi|tion"
column subpartition_count format 999  heading "Sub|cnt"
column tablespace_name    format a15  heading "Table space|Name"
column inital_ex_size_mb  format 9999 heading "Inital Ex|MB"
column size_on_disk       format 99999999 heading "Size on disk|MB"

ttitle  "Portions Overview of the table &&OWNER..&&TAB_NAME."  SKIP 1

select    p.partition_position
       ,  p.partition_name
       ,  p.subpartition_count
       ,  p.tablespace_name
	   ,  (p.initial_extent/1024/1024) as inital_ex_size_mb
	   ,  round((s.bytes/1024/1024),0) as size_on_disk	  
  from dba_tab_partitions p, dba_segments s  
where p.table_owner like upper('&&OWNER.')
  and p.table_name like upper('&&TAB_NAME.')
  and p.table_name= s.SEGMENT_NAME (+)
  and p.partition_name= s.PARTITION_NAME (+)
  and p.table_owner = s.owner (+)
order by p.partition_position  
/

ttitle  "Portions last value of the table &&OWNER..&&TAB_NAME."  SKIP 1

column partition_position format 99    heading "Pos"
column partition_name     format a30   heading "Part|Name" 
column HIGH_VALUE         format a100  heading "Portions High Value" fold_before


--------------------
-- read long buffer to read long values
set long 32767
--------------------

select    p.partition_position
       ,  p.partition_name
       ,  HIGH_VALUE
  from dba_tab_partitions p
     , dba_segments s  
where p.table_owner like upper('&&OWNER.')
  and p.table_name like upper('&&TAB_NAME.')
  and p.table_name= s.SEGMENT_NAME (+)
  and p.partition_name= s.PARTITION_NAME (+)
  and p.table_owner = s.owner (+)
order by p.partition_position  
/


-----------------------
-- get the last partition of the table
----------------------


ttitle  "Last Portions of the table &&OWNER..&&TAB_NAME."  SKIP 1

select out.TABLE_OWNER
     , out.TABLE_NAME
	  , out.PARTITION_NAME
	  , out.HIGH_VALUE 
 from dba_tab_partitions out
where PARTITION_POSITION = (select max(PARTITION_POSITION) 
                              from dba_tab_partitions inner
                              where out.TABLE_OWNER = inner.TABLE_OWNER 
										  and out.TABLE_NAME  = inner.TABLE_NAME)
 and out.table_owner like upper('&&OWNER.')
 and out.table_name  like upper('&&TAB_NAME.')
order by TABLE_OWNER
        ,TABLE_NAME
/

column partition_position clear
column partition_name     clear

ttitle off

