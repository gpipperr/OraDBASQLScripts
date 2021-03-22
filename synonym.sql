--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get summary over synonyms
--
-- Must be run with dba privileges
--
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define OWNER     = '&1' 
define TYPE_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = Type       => &&TYPE_NAME.

column owner        format a15 heading "Synonym|Owner"
column table_owner  format a15 heading "Object|Owner"
column object_type  format a15 heading "Object|Type"
column obj_count    format 999G999 heading "Object|Count"
column synonym_name format  a27 heading "Synonym|Name"
column table_name   format  a27 heading "Object|Name"
column db_link      format  a10 heading "DB|Link"


ttitle  "Overview over all Synonyms and types"  SKIP 2 -

select obj.object_type 
     , syn.owner
     , syn.table_owner
	 , count(*)  as obj_count
from  dba_objects obj
    , dba_synonyms syn
where syn.table_owner=upper('&&OWNER.') 
  and syn.table_owner=obj.owner 	 
  and obj.object_name=syn.table_name
group by syn.owner
     , syn.table_owner
	 , obj.object_type
order by obj.object_type  	  
/  

ttitle  "Detail for this type &&TYPE_NAME."  SKIP 2 -
 
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
  and obj.object_type like upper('&&TYPE_NAME.%') 
order by obj.object_type,syn.synonym_name  
/

ttitle "delete Script for invalid synonym - synonym points on an not existing object" SKIP 2

select 'drop ' || decode(s.owner, 'PUBLIC', 'PUBLIC SYNONYM ', 'SYNONYM ' || s.owner || '.') || s.synonym_name || ';' as DELETE_ME
  from dba_synonyms s
 where s.table_owner=upper('&&OWNER.') 
   and (db_link is null or db_link = 'PUBLIC')
   and not exists (select 1
                     from dba_objects o
                    where decode(s.table_owner, 'PUBLIC', o.owner, s.table_owner) = o.owner
                      and s.table_name = o.object_name
						)
/
 
prompt

ttitle off
