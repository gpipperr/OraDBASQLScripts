--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk Overview
-- Date: 2016
--==============================================================================
set linesize 130 pagesize 300 recsep off

define DG_NAME = '&1'

prompt
prompt Parameter 1 = Data Group Name          => &&DG_NAME.
prompt

column GROUP_NAME  format A20 heading "Group|name"
column DISK_NAME   format A20 heading "Disk|name"
column FAILGROUP   format A30 heading "Failgroup|name"
column path        format A30 heading "Disk|path"

ttitle left  "ASM Failgroups of a Diskgroup" skip 2

select g.name  as group_name
     , d.failgroup
     , d.name as disk_name
	 , d.path
	 --, d.header_status
     --, d.mount_status
     , d.mode_status
 from v$asm_disk d 
      inner join  v$asm_diskgroup g on (g.group_number=d.group_number)
where g.name like upper ('&&DG_NAME')
order by d.name,d.FAILGROUP
/

ttitle off

prompt ... to online / offline all disks in a failgroup
prompt ... ALTER diskgroup &&DG_NAME. online|offline disks in failgroup <fail_group>;
prompt ...