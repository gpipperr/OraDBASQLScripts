--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the sql execution plan for this sql id from Cursor Cache
-- Date:   September 2013
--
--==============================================================================
-- http://psoug.org/reference/dbms_xplan.html
--  
-- http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_xplan.htm
-- 
-- format
-- 
-- Controls the level of details for the plan. It accepts four values:
-- 
-- 	BASIC: Displays the minimum information in the plan—the operation ID, the operation name and its option.
-- 	TYPICAL: This is the default. Displays the most relevant information in the plan (operation id, name and option, #rows, #bytes and optimizer cost). Pruning, parallel and predicate information are only displayed when applicable. Excludes only PROJECTION, ALIAS and REMOTE SQL information (see below).
-- 	SERIAL: Like TYPICAL except that the parallel information is not displayed, even if the plan executes in parallel.
-- 	ALL: Maximum user level. Includes information displayed with the TYPICAL level with additional information (PROJECTION, ALIAS and information about REMOTE SQL if the operation is distributed).
-- 
-- For finer control on the display output, the following keywords can be added to the above three standard format options to customize their default behavior. Each keyword either represents a logical group of plan table columns (such as PARTITION) or logical additions to the base plan table output (such as PREDICATE). Format keywords must be separated by either a comma or a space:
-- 	ROWS - if relevant, shows the number of rows estimated by the optimizer
-- 	BYTES - if relevant, shows the number of bytes estimated by the optimizer
-- 	COST - if relevant, shows optimizer cost information
-- 	PARTITION - if relevant, shows partition pruning information
-- 	PARALLEL - if relevant, shows PX information (distribution method and table queue information)
-- 	PREDICATE - if relevant, shows the predicate section
-- 	PROJECTION -if relevant, shows the projection section
-- 	ALIAS - if relevant, shows the "Query Block Name / Object Alias" section
-- 	REMOTE - if relevant, shows the information for distributed query (for example, remote from serial distribution and remote SQL)
-- 	NOTE - if relevant, shows the note section of the explain plan
-- 
-- For RAC see https://carlos-sierra.net/2013/06/17/using-dbms_xplan-to-display-cursor-plans-for-a-sql-in-all-rac-nodes/
--
--==============================================================================

define SQL_ID = &1 

set verify off
set linesize 190 pagesize 300 

ttitle left  "SQL Plan from Cursor Cache ID:  &SQL_ID." skip 2

column out_put format a190 heading "SQL Plan Output"

select PLAN_TABLE_OUTPUT as out_put
 from TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&SQL_ID.',null,'TYPICAL'))
/ 

ttitle off
