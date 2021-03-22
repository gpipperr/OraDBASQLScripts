--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk Overview
-- Date: 2016
--==============================================================================
set linesize 130 pagesize 300 recsep off

define DISK_NAME = '&1'

prompt
prompt Parameter 1 = Data Group Name  => &&DISK_NAME.
prompt

column GROUP_NAME  format A20 heading "Group|name"
column DISK_NAME   format A20 heading "Disk|name"
column FAILGROUP   format A30 heading "Failgroup|name"
column path        format A30 heading "Disk|path"
column command     format a125

ttitle left  "ASM Offline all Disks of this Failgroups" skip 2

select   'ALTER diskgroup '|| g.name
       ||' offline disks IN failgroup '
	   || d.FAILGROUP 
	   ||';'  as command
from v$asm_disk d 
      inner join  v$asm_diskgroup g on (g.group_number=d.group_number)
where d.path like upper ('%-_&&DISK_NAME.') ESCAPE '-'
group by d.FAILGROUP,g.name
;

ttitle left  "ASM online all Disks of this Failgroups" skip 2
select   'ALTER diskgroup '|| g.name
       ||' online disks IN failgroup '
	   || d.FAILGROUP 
	   ||';' 
from v$asm_disk d 
      inner join  v$asm_diskgroup g on (g.group_number=d.group_number)
where d.path like upper ('%-_&&DISK_NAME.') ESCAPE '-'
group by d.FAILGROUP,g.name
;

ttitle off

prompt ... to online / offline all disks in a failgroup
prompt ... ALTER diskgroup <group> online|offline disks in failgroup <fail_group>;
prompt ...