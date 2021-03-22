--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Which objects depends on this pl/sql code
--==============================================================================
set verify  off
set linesize 130 pagesize 300 
set trimspool on

-- v$sql has it, program_id is the object_id of the plsql routine. 


column owner       format a20
column object_type format a20 heading "Object|Type"
column object_name format a30 heading "Object|Name"
column min_first_load format a18
column max_first_load format a18


select count(*)
    , obj.owner
    , obj.object_type
    , obj.object_name
	--, s.PROGRAM_LINE# 
    --, obj.subobject_name
    , min(to_date(s.first_load_time,'YYYY-MM-DD/HH24:MI:SS')) as min_first_load
    , max(to_date(s.first_load_time,'YYYY-MM-DD/HH24:MI:SS')) as max_first_load    
  from dba_objects obj
     , v$sql s
 where s.program_id = obj.object_id
   and s.program_id != 0
 group by obj.owner
        , obj.object_type
        , obj.object_name
        , obj.subobject_name   
	--  , s.PROGRAM_LINE# 
    --  , obj.subobject_name
order by obj.owner  
/
