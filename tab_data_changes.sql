--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get an overview over changes on the tables of a user - parameter - Owner
--==============================================================================
----http://www.oracleangels.com/2011/01/automatic-statistics-gathering-job.html
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt 


select num_rows
     , last_analyzed
	 , tot_updates
	 , table_owner
	 , table_name
	  --, partition_name
	  --, subpartition_name
	  --, inserts
	 -- , updates
	  --, deletes
	 -- , timestamp
--, truncated
	  , to_char(perc_updates, 'FM999,999,999,990.00') perc_updates
from (
        select a.* , nvl(decode(num_rows, 0, '-1', 100 * tot_updates / num_rows), -1) perc_updates
        from (
          select
                  (select num_rows 
						   from dba_tables 
						 where dba_tables.table_name = DBA_TAB_MODIFICATIONS.table_name
                     and DBA_TAB_MODIFICATIONS.table_owner = dba_tables.owner) num_rows
                , (select last_analyzed 
					      from dba_tables 
						  where dba_tables.table_name = DBA_TAB_MODIFICATIONS.table_name
                      and DBA_TAB_MODIFICATIONS.table_owner = dba_tables.owner) last_analyzed
                , (inserts + updates + deletes) tot_updates
                , DBA_TAB_MODIFICATIONS.*
    		 from sys.DBA_TAB_MODIFICATIONS
        ) a
) b
where perc_updates > 10 
 and table_owner = upper('&&OWNER.')
/

