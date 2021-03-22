--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc:   show asm balance
-- Date:   November 2013
--==============================================================================
set linesize 130 pagesize 300 


define DG_NAME = '&1'

prompt
prompt Parameter 1 = Data Group Name          => &&DG_NAME.
prompt

column bytes        format 999G999G999G999  heading "Bytes|total"  
column group_number format 999     heading "Grp|Nr"
column file_name    format a50     heading "File|Name"
column doublecount  format 99      heading "File|Count"
column GROUP_NAME   format A20     heading "Group|name"

ttitle left  "ASM Disk Status and Size" skip 2

select  g.name as GROUP_NAME
      , a.name as file_name
      , b.bytes 
      , count(*) over(partition by a.group_number, a.file_number, a.file_incarnation) doublecount
  from  v$asm_alias a
      , v$asm_file  b
	  , v$asm_diskgroup g
where  g.name like upper ('&&DG_NAME')
   and g.group_number     = b.group_number
   and a.group_number     = b.group_number
   and a.file_number      = b.file_number
   and a.file_incarnation = b.incarnation
/

ttitle off

