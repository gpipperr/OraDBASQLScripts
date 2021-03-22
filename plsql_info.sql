--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  show more informations about a plsql object
-- Must be run with DBA privileges
--==============================================================================
-- http://docs.oracle.com/cd/B28359_01/server.111/b28320/statviews_2009.htm#REFRN20385
-- http://docs.oracle.com/cd/B28359_01/server.111/b28320/statviews_2013.htm#REFRN20168
-- http://www.oracle.com/technetwork/issue-archive/2012/12-nov/o62plsql-1851968.html
-- http://docs.oracle.com/cd/E16655_01/network.121/e17607/dr_ir.htm#DBSEG658
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define OBJ_NAME = '&1' 

prompt
prompt Parameter 1 = PLSQL NAME         => &&OBJ_NAME.
prompt

column owner                format a15
column name                 format a15
column type                 format a12
column plsql_optimize_level format 99  heading "OL"
column plsql_code_type      format a12 heading "Code|Type" 
column plsql_debug			 format a8  heading "Debug"
column plsql_warnings       format a15 heading "Warn"
column nls_length_semantics format a15 
column plsql_ccflags        format a10 heading "CC Flag" 
column plscope_settings     format a18

select 
	  owner               
	, name                
	, type                
	, plsql_optimize_level
	, plsql_code_type     
	, plsql_debug			
	, plsql_warnings      
	--, nls_length_semantics
	, plsql_ccflags       
	, plscope_settings    
 from dba_plsql_object_settings 
where NAME like upper('&&OBJ_NAME.');

column object_name    format a20
column procedure_name format a20
column overload 		 format a20
column object_type 	 format a20
column impltypeowner  format a20
column impltypename 	 format a20
column authid 			 format a20

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

prompt ... AUTHID - Indicates whether the procedure/function is declared to execute as DEFINER or CURRENT_USER (invoker)

select owner
--  ,  subobject_name
    ,  object_type
    ,  to_char(created,'dd.mm.yyyy hh24:mi') as created
	,  to_char(last_ddl_time,'dd.mm.yyyy hh24:mi') as last_ddl_time
	,  timestamp
	,  status
from dba_objects
where OBJECT_NAME like  upper('&&OBJ_NAME.')
/
