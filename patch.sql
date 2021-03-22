--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Patch info 12c
-- Date:   November 2017
--
--==============================================================================

set verify off
set linesize 130 pagesize 300 
set long 64000



select * 
  from dba_registry_sqlpatch
order by PATCH_ID
/


--------------------------------------------------------------------------------