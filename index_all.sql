--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get all indexes of a user - parameter - Owner
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define OWNER = '&1'


prompt
prompt Parameter 1 = Owner       => &&OWNER.
prompt

ttitle center "All Indexes of this Owner: &&OWNER. " skip 2

column compression   format a9 heading "Comp"
column blevel        format 999 heading "BLevel"
column block_rate    format 999 heading "B Rate"
column leaf_blocks   format 99999999999 heading "Leaf"
column blocks        format 99999999999 heading "Blocks"
column num_rows      format 99999999999 heading "Num Rows"
column distinct_keys format 99999999999 heading "Distinct | Keys"
column avg_leaf_blocks_per_key format 999 heading "AVG|L-Blk."
column avg_data_blocks_per_key format 999 heading "AVG|Data-Blk."
column status                    format a6 heading "Status"
column  index_owner format a10 heading "Index|Owner"
column  index_name  format a26 heading "Index|Name"
column  table_name  format a13 heading "Table|Name"

select i.COMPRESSION
       ,  i.blevel
       ,  i.leaf_blocks
       ,  s.blocks
       --,  decode(nvl(i.leaf_blocks,0),0,0,(s.blocks/i.leaf_blocks)) as block_rate
       ,  i.NUM_ROWS
       ,  i.DISTINCT_KEYS
       --,  i.AVG_LEAF_BLOCKS_PER_KEY
       --,  i.AVG_DATA_BLOCKS_PER_KEY
       ,  i.status
       ,  i.index_name
       ,  to_char (o.LAST_DDL_TIME, 'dd.mm.rr hh24:mi') as Created
    from dba_indexes i, dba_segments s, DBA_OBJECTS o
   where s.owner = i.owner
     and s.SEGMENT_NAME = i.index_name
	 and nvl(s.partition_name,'n/a')=nvl(o.subobject_name,'n/a')
     and o.object_name = i.index_name
     and o.owner = i.owner
	-- and i.owner like upper ('&&OWNER.')
	and o.owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','PUBLIC','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT','PUBLIC','TSMSYS')
	-- and o.LAST_DDL_TIME  between sysdate-14 and sysdate
order by o.LAST_DDL_TIME
/
