--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show init.parameter in a RAC Environment to check if same parameters on each node
-- Date: 01.September 2012
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "Check Rac init.ora non default parameter if equal" skip 2

column parameter       format a30
column value_instance1 format a30 heading "Value|Inst 1"
column value_instance2 format a25 heading "Value|Inst 2"
column value_instance3 format a10 heading "Value|Inst 3"
column value_instance4 format a10 heading "Value|Inst 4"

select  inst1.name as parameter
      , inst1.VALUE as value_instance1
      , inst2.VALUE as value_instance2
	  , inst3.VALUE as value_instance3
	  , inst4.VALUE as value_instance4
  from (select * from gv$parameter where (isdefault != 'TRUE' or name in ('parameter','nls_language','nls_territory','nls_length_semantics') )and inst_id=1) inst1
      ,(select * from gv$parameter where (isdefault != 'TRUE' or name in ('parameter','nls_language','nls_territory','nls_length_semantics') )and inst_id=2) inst2
	  ,(select * from gv$parameter where (isdefault != 'TRUE' or name in ('parameter','nls_language','nls_territory','nls_length_semantics') )and inst_id=3) inst3
	  ,(select * from gv$parameter where (isdefault != 'TRUE' or name in ('parameter','nls_language','nls_territory','nls_length_semantics') )and inst_id=4) inst4
 where inst1.name = inst2.name (+)
 and   inst1.name = inst3.name (+)
 and   inst1.name = inst4.name (+)
order by 1 
/

ttitle off 