--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the plan of the last "explain plan for"
--==============================================================================

set verify  off
set linesize 170 pagesize 4000 

--ALLSTATS LAST NOTE


/*

http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_xplan.htm

format

Controls the level of details for the plan. It accepts four values:

	BASIC: Displays the minimum information in the plan—the operation ID, the operation name and its option.
	TYPICAL: This is the default. Displays the most relevant information in the plan (operation id, name and option, #rows, #bytes and optimizer cost). Pruning, parallel and predicate information are only displayed when applicable. Excludes only PROJECTION, ALIAS and REMOTE SQL information (see below).
	SERIAL: Like TYPICAL except that the parallel information is not displayed, even if the plan executes in parallel.
	ALL: Maximum user level. Includes information displayed with the TYPICAL level with additional information (PROJECTION, ALIAS and information about REMOTE SQL if the operation is distributed).

For finer control on the display output, the following keywords can be added to the above three standard format options to customize their default behavior. Each keyword either represents a logical group of plan table columns (such as PARTITION) or logical additions to the base plan table output (such as PREDICATE). Format keywords must be separated by either a comma or a space:
	ROWS - if relevant, shows the number of rows estimated by the optimizer
	BYTES - if relevant, shows the number of bytes estimated by the optimizer
	COST - if relevant, shows optimizer cost information
	PARTITION - if relevant, shows partition pruning information
	PARALLEL - if relevant, shows PX information (distribution method and table queue information)
	PREDICATE - if relevant, shows the predicate section
	PROJECTION -if relevant, shows the projection section
	ALIAS - if relevant, shows the "Query Block Name / Object Alias" section
	REMOTE - if relevant, shows the information for distributed query (for example, remote from serial distribution and remote SQL)
	NOTE - if relevant, shows the note section of the explain plan


*/

SELECT * FROM TABLE( dbms_xplan.display( NULL, NULL, 'ALL,COST', NULL ))
/

