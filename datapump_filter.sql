--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  Show the Data Pump Export/Import Filters
-- Parameter 1: Name of the Export Type
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define DP_TYPE = '&1'
define DP_PATH = '&2'

prompt
prompt Parameter 1 = Data Pump Type        => &&DP_TYPE.
prompt Parameter 2 = Data Pump PATH       => &&DP_PATH.
prompt

column seq_num     format 999999 
column full_path  format a80 heading "Full Name of the Object" 
column het_type   format a40 heading "Data Pump|Type of Ex/Import"

select seq_num
     , full_path
     , het_type
 from sys.datapump_paths
where het_type like upper('&&DP_TYPE.%')
  and full_path like upper('%&&DP_PATH.%')
order by het_type,seq_num
/


