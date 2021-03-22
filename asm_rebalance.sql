--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk rebalance overview
-- Date: 2016
--==============================================================================
set linesize 130 pagesize 300 recsep off

column GROUP_NUMBER  format 9999 heading "Group|Nr"
column GROUP_NAME    format A10  heading "Group|name"
                                                                
column OPERATION   format a5  heading "Oper"
column PASS        format a10 heading "Pass"                                                                       
column STATE       format a4  heading "State"
column POWER       format 999 heading "Po|wer" 
column ACTUAL      format 99999       
column SOFAR       format 99999       
column EST_WORK    format 99999       
column EST_RATE    format 99999       
column EST_MINUTES format 99999      
column ERROR_CODE  format A10  heading "Error|code"
column CON_ID      format 99

ttitle left  "ASM actual rebalance operations" skip 2

SELECT g.name  as GROUP_NAME
     , o.PASS
	 , o.STATE
	 , o.POWER
	 , o.ACTUAL
	 , o.SOFAR
	 , o.EST_MINUTES
	 , o.ERROR_CODE
  FROM v$asm_operation o
       inner join  v$asm_diskgroup g on (g.group_number=o.group_number)
order by g.name
/

ttitle off

prompt .... if possible use more threads to resync
prompt .... ALTER diskgroup vot rebalance POWER 9

prompt
