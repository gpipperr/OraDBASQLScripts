--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show information about a index
-- Parameter 1: Owner of the index
-- Parameter 2: Index Name
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define OWNER = '&1'
define INDEX_NAME = '&2'

prompt
prompt Parameter 1 = Owner       => &&OWNER.
prompt Parameter 2 = Index Name  => &&INDEX_NAME.
prompt


column  index_owner format a10 heading "Index|Owner"
column  index_name  format a25 heading "Index|Name"
column  status      format a12 heading "Status"
column part_info    format 999 heading "Partition|count"

ttitle "Check the Status of the Index" skip 2

select owner as index_owner
     ,  index_name
     ,  status
     ,  0 as part_info
  from dba_indexes
 where     owner like upper ('&&OWNER.%')
       and index_name like upper ('%&&INDEX_NAME.')
union
  select index_owner
       ,  index_name
       ,  status
       ,  count (partition_name)
    from dba_ind_partitions
   where     status not in ('VALID', 'N/A', 'USABLE')
         and index_owner like upper ('&&OWNER.%')
         and index_name like upper ('&&INDEX_NAME.')
group by index_owner, index_name, status
/



ttitle center "Index &&OWNER..&&INDEX_NAME.  Columns" skip 2

set linesize 130 pagesize 2000 

column  index_name  format a16 heading "Index|Name"
column  table_name  format a13 heading "Table|Name"
column  column_name format a13 heading "Column|Name"
column TABLESPACE_NAME format a15 heading "Table|Space"
-- fold_before
column  pos1        format a12 heading "c1"
column  pos2        format a8 heading "c2"
column  pos3        format a6  heading "c3"
column  pos4        format a4  heading "c4"
column  pos5        format a4  heading "c5"
column  pos6        format a4  heading "c6"
-- if you like more enable!
column  pos7        format a3  heading "c7" noprint
column  pos8        format a3  heading "c8" noprint
column  pos9        format a2  heading "c9" noprint
--
column size_mb      format 999G999G999 heading "Size|MB"
column part_count   format 9G999 heading "Cn|Pa"


  select i.INDEX_OWNER
       ,  i.TABLE_NAME
       ,  i.INDEX_NAME
       ,  round (  sum (s.bytes)
                 / 1024
                 / 1024
               ,  0)
             size_mb
       ,  count (s.PARTITION_NAME) as part_count
       ,  i.pos1
       ,  i.pos2
       ,  i.pos3
       ,  i.pos4
       ,  i.pos5
       ,  i.pos6
       ,  i.pos7
       ,  i.pos8
       ,  i.pos9
       ,  s.TABLESPACE_NAME
    from (select *
            from (  select index_owner
                         ,  table_name
                         ,  index_name
                         ,  column_name
                         ,  column_position
                      from dba_ind_columns
                     where     index_owner like upper ('&&OWNER.%')
                           and index_name like upper ('&&INDEX_NAME.')
                  order by index_owner, table_name) pivot (min (column_name)
                                                    for column_position
                                                    in  ('1' as pos1
                                                      ,  '2' as pos2
                                                      ,  '3' as pos3
                                                      ,  '4' as pos4
                                                      ,  '5' as pos5
                                                      ,  '6' as pos6
                                                      ,  '7' as pos7
                                                      ,  '8' as pos8
                                                      ,  '9' as pos9))) i
       ,  dba_segments s
   where     s.owner = i.index_owner
         and s.SEGMENT_NAME = i.INDEX_NAME
group by i.INDEX_OWNER
       ,  i.TABLE_NAME
       ,  i.INDEX_NAME
       ,  i.pos1
       ,  i.pos2
       ,  i.pos3
       ,  i.pos4
       ,  i.pos5
       ,  i.pos6
       ,  i.pos7
       ,  i.pos8
       ,  i.pos9
       ,  s.TABLESPACE_NAME
/

--ttitle center "Index &&OWNER..&&INDEX_NAME.  Partitions" SKIP 2

ttitle center "Index &&OWNER..&&INDEX_NAME.  Statistic" skip 2

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
column PARTITION_NAME   format a20 heading "Part|Name"


select nvl (s.PARTITION_NAME, 'N/A') as PARTITION_NAME
     ,  i.COMPRESSION
     ,  i.blevel
     ,  i.leaf_blocks
     ,  s.blocks
     ,  decode (nvl (i.leaf_blocks, 0)
              ,  0, 0
              ,  (  s.blocks
                  / i.leaf_blocks))
           as block_rate
     ,  i.NUM_ROWS
     ,  i.DISTINCT_KEYS
     ,  i.AVG_LEAF_BLOCKS_PER_KEY
     ,  i.AVG_DATA_BLOCKS_PER_KEY
     ,  i.status
     ,  to_char (i.LAST_ANALYZED, 'dd.mm.rr hh24:mi') as LAST_ANALYZED
     ,  to_char (o.LAST_DDL_TIME, 'dd.mm.rr hh24:mi') as Created
  from dba_indexes i, dba_segments s, DBA_OBJECTS o
 where     s.owner = i.owner
       and s.SEGMENT_NAME = i.index_name
       and o.object_name = i.index_name
       and nvl (o.SUBOBJECT_NAME, 'X') = nvl (s.PARTITION_NAME, 'X')
       and o.owner = i.owner
       and i.owner like upper ('&&OWNER.%')
       and i.index_name like upper ('&&INDEX_NAME.')
/

ttitle off