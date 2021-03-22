--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get detail over one synonym
--
-- Must be run with dba privileges
--
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define OWNER     = '&1' 
define SYN_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = SYN_NAME   => &&SYN_NAME.

column owner        format a15 heading "Synonym|Owner"
column table_owner  format a15 heading "Object|Owner"
column object_type  format a15 heading "Object|Type"
column obj_count    format 999G999 heading "Object|Count"
column synonym_name format  a27 heading "Synonym|Name"
column table_name   format  a27 heading "Object|Name"
column db_link      format  a10 heading "DB|Link"


ttitle  "Detail for this synonym &&SYN_NAME."  SKIP 2 -
 
select syn.owner
      , syn.synonym_name
	  , syn.table_owner
	  , syn.table_name
	  , syn.db_link
	  , obj.object_type
from dba_objects obj
    ,dba_synonyms syn
where syn.table_owner=upper('&&OWNER.') 
  and syn.table_owner=obj.owner 
  and obj.object_name=syn.table_name
  and syn.synonym_name like upper('&&SYN_NAME.%') 
order by obj.object_type,syn.synonym_name  
/
  
prompt

ttitle off


