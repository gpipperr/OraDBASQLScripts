--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk Overview
-- Date: 2016
--==============================================================================
set linesize 130 pagesize 300 recsep off

column command     format a125

ttitle left  "ASM online all Disks of Failgroups if Path is null" skip 2


select   'ALTER diskgroup '|| g.name
       ||' online disks IN failgroup '
	   || d.FAILGROUP 
	   ||';'  as command
from v$asm_disk d 
     inner join  v$asm_diskgroup g on (g.group_number=d.group_number)
where d.path is null
group by d.FAILGROUP,g.name
;

ttitle off

prompt ... to online / offline all disks in a failgroup
prompt ... ALTER diskgroup <group> online|offline disks in failgroup <fail_group>;
prompt ...
prompt ... check with @asm_rebalance the rebalance jobs
prompt ...
