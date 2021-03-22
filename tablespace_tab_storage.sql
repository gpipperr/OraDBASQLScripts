--==============================================================================
-- GPI - Gunther Pippèrr
-- In Work!
-- Desc: show all tables on a tablespace
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define TABLESPACE_NAME = '&1'

column TABLE_NAME format a25 heading "Table|Name"

  select TABLE_NAME
       ,  owner
       ,  PCT_FREE
       ,  PCT_USED
       ,  INI_TRANS
       ,  MAX_TRANS
       ,  INITIAL_EXTENT
       ,  NEXT_EXTENT
       ,  NEXT_EXTENT / 8192  frag_factor
    --,MIN_EXTENTS
    --,MAX_EXTENTS
    --,PCT_INCREASE
    --,FREELISTS
    --,FREELIST_GROUPS
    from dba_tables
   where tablespace_name = upper ('&&TABLESPACE_NAME.')
order by NEXT_EXTENT
/