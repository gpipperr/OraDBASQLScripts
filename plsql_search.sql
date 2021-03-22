--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: search for a plsql function/procedure also in packages - parameter Search String
--==============================================================================
set linesize 130 pagesize 300 

column object_name    format a25
column procedure_name format a25
column overload 		 format a20
column object_type 	 format a20
column impltypeowner  format a20
column impltypename 	 format a20
column authid 			 format a20


define OBJ_NAME = '&1' 

prompt
prompt Parameter 1 = PLSQL NAME         => &&OBJ_NAME.
prompt


select owner 
	,  OBJECT_NAME
	,	PROCEDURE_NAME
    --, OVERLOAD
	, OBJECT_TYPE
    --,AGGREGATE
	 --,PIPELINED
	 --,IMPLTYPEOWNER
	 --,IMPLTYPENAME
	 --,PARALLEL
	 --,INTERFACE
	, DETERMINISTIC
	, AUTHID
 from dba_procedures  
where object_name like upper('&&OBJ_NAME.')
/


select owner 
	,  OBJECT_NAME
	,	PROCEDURE_NAME
    --, OVERLOAD
	, OBJECT_TYPE
    --,AGGREGATE
	 --,PIPELINED
	 --,IMPLTYPEOWNER
	 --,IMPLTYPENAME
	 --,PARALLEL
	 --,INTERFACE
	, DETERMINISTIC
	, AUTHID
 from dba_procedures  
where PROCEDURE_NAME like upper('&&OBJ_NAME.')
/