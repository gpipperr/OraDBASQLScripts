--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk Overview
-- Date: 2016
--==============================================================================
set linesize 130 pagesize 300 recsep off

define DG_NAME = '&1'
define PRAM_NAME = '&2'

prompt
prompt Parameter 1 = Data Group Name          => &&DG_NAME.
prompt Parameter 2 = Parameter Name           => &&PRAM_NAME.
prompt

column GROUP_NAME  format A10 heading "Group|name"
column NAME        format A50 heading "Propertiy|name"
column value       format A20 heading "Value"
column SYSTEM_CREATED format a7 heading "System|created"

ttitle left  "ASM Attributes" skip 2

select g.name  as group_name
     , a.name
     , a.value
	 , a.SYSTEM_CREATED
  from V$ASM_ATTRIBUTE a
      inner join  v$asm_diskgroup g on (g.group_number=a.group_number)
where g.name like upper ('&&DG_NAME') 
  and a.name like lower ('%&&PRAM_NAME%') 
order by a.name
       , g.name
/

ttitle off

prompt ... to set a parameter
prompt ... like : ALTER DISKGROUP <disk group> SET ATTRIBUTE 'compatible.asm'='11.2.0.0.0'
prompt ...