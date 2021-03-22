--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: show the lob settings of the tables of the user - parameter - Owner
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define OWNER    = '&1' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt

column owner        format a11 heading "User"
column table_name   format a19 heading "Table name"
column column_name  format a19 heading "Column|Name"
column segment_name format a25 heading "Segment|Name"
column IN_ROW       format a3 heading "In|Row"
column SECUREFILE   format a3 heading "Sec|File"
column tablespace_name format a10        heading "Tab|Space"
column mb              format 999G999D99 heading "Size|MB"
column PARTITION_NAME  format a8 heading "Part|Name"

select --l.owner
    --,  
	    l.table_name
	 ,  l.column_name
	 ,  l.tablespace_name
	 ,  l.segment_name  
	 ,  substr(s.PARTITION_NAME,1,6)||'..' as PARTITION_NAME
	 ,  round(decode(nvl(s.bytes,0),0,0,(s.bytes/1024/1024)),2) as mb
	 ,  l.in_row
	 ,  l.securefile
from dba_lobs l
   , dba_segments s
where l.segment_name  = s.segment_name(+)
  and upper(l.owner)=upper('&&OWNER.')
order by   l.table_name
/

