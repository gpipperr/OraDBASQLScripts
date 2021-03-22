--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  purge the cursor out of the cache  - parameter 1 - SQL ID
--==============================================================================
-- http://kerryosborne.oracle-guy.com/2008/09/flush-a-single-sql-statement/
-- http://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/cursor_invalidieren/index.html
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define SQL_ID='&1'

prompt
prompt Parameter 1 = SQL ID     => &&SQL_ID.
prompt

set pagesize 100
set linesize 130

select address
     , hash_value
	 , executions
	 , invalidations
	 , parse_calls
	 , substr(sql_text,1,20)||'...' as sql_text
  from v$sqlarea
 where sql_id like '&&SQL_ID.'
/  

set serveroutput on

declare
 v_name varchar2(30); 
begin

 select address||','||hash_value into v_name
   from gv$sqlarea
  where sql_id like '&&SQL_ID.';
 
dbms_output.put_line('Info -- invalidate Cursor of this statement &&SQL_ID.  :: '||v_name);
 
sys.dbms_shared_pool.purge(name => v_name
                         , flag => 'C'
						 , heaps   => 1);

end;
/


select address
     , hash_value
	 , executions
	 , invalidations
	 , parse_calls
	 , substr(sql_text,1,20)||'...' as sql_text
  from v$sqlarea
 where sql_id like '&&SQL_ID.'
/  


--==============================================================================
-- 
-- see http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_shared_pool.htm#CHDCBEBB 
-- Parameter Description 
-- name
--  Name of the object to purge.
-- 
-- The value for this identifier is the concatenation of the address and hash_value columns from the v$sqlarea view. This is displayed by the SIZES procedure.
-- 
-- Currently, TABLE and VIEW objects may not be purged.
--  
-- flag
--  (Optional) If this is not specified, then the package assumes that the first parameter is the name of a package/procedure/function and resolves the name.
-- 
-- Set to 'P' or 'p' to fully specify that the input is the name of a package/procedure/function.
-- 
-- Set to 'T' or 't' to specify that the input is the name of a type.
-- 
-- Set to 'R' or 'r' to specify that the input is the name of a trigger.
-- 
-- Set to 'Q' or 'q' to specify that the input is the name of a sequence.
-- 
-- In case the first argument is a cursor address and hash-value, the parameter should be set to any character except 'P' or 'p' or 'Q' or 'q' or 'R' or 'r' or 'T' or 't'.
--  
-- heaps
--  Heaps to be purged. For example, if heap 0 and heap 6 are to be purged:
-- 
-- 1<<0 | 1<<6 => hex 0x41 => decimal 65, so specify heaps =>65.Default is 1, that is, heap 0 which means the whole object would be purged
--  
--==============================================================================
