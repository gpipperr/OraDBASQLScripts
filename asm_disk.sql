--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: SQL Script ASM Disk Overview
-- Date: 2012
--==============================================================================
-- http://jarneil.wordpress.com/2008/04/10/keep-disks-in-your-diskgroup-the-same-size/
-- http://docs.oracle.com/cd/E24628_01/em.121/e25160/asm_cluster.htm#EMDBM10000
--==============================================================================
set linesize 130 pagesize 300 recsep off

ttitle left  "ASM Disk Status and Size" skip 2

define dnum = "format 999G999G999G999D99"
define lnum = "format 9G999G999"
define num  = "format 99G999"
define snum  = "format 9G999"

column total_mb &&lnum
column group_number format 99  heading "Grp Nr."
column inst_id format 99  heading "Inst"
column status  format A6
column state  format A10 heading "State"
column type  format A6  heading "Type"
column name  format A20
column free &&lnum
column used &&lnum

column writes &&dnum
column reads &&dnum
column read_errs &&snum   heading "R Er."
column write_errs &&snum  heading "W Er."
column r_tim &&dnum  heading "R Tim."
column w_tim &&dnum heading "W Tim."
column bytes_read &&num
column bytes_written &&num
column INSTANCE_NAME format A10
column free_percent format a6 heading "free|%"
column free_netto format 999G999G999 heading "Usable|netto"
column Netto      format 999G999G999 heading "Usable|total"
column Brutto     format 999G999G999 heading "Disk|total"  
column disk_count format 999 heading "Disk|cnt"
column disk_count_vot format 999 heading "Vot|cnt"	
column header_status format a14 heading "Header|Status"
column mount_status format a14 heading "Mount|Status"
column mode_status format a14 heading "Mode|Status"
column repair_timer &&lnum heading "Repair|Timer"

ttitle left  "Check Status of the ASM Disk over all groups" skip 2

SELECT count(*)
   , header_status
   , mount_status
   , mode_status
   , state
   , repair_timer
 FROM v$asm_disk
 group by header_status
   , mount_status
   , mode_status
   , state
   , repair_timer
 order by mode_status  ;

 
-- prompt ... 
-- prompt ... Mount status of the disk :
-- prompt ... 
-- prompt ... MISSING - Oracle ASM metadata indicates that the disk is known to be part of the Oracle ASM disk group but no disk in the storage system was found with the indicated name
-- prompt ... CLOSED - Disk is present in the storage system but is not being accessed by Oracle ASM
-- prompt ... OPENED - Disk is present in the storage system and is being accessed by Oracle ASM. This is the normal state for disks in a database instance which are part of a Disk Group being actively used by the instance.
-- prompt ... CACHED - Disk is present in the storage system and is part of a disk group being accessed by the Oracle ASM instance. This is the normal state for disks in an Oracle ASM instance which are part of a mounted disk group.
-- prompt ... IGNORED - Disk is present in the system but is ignored by Oracle ASM because of one of the following:
-- prompt ...          The disk is detected by the system library but is ignored because an Oracle ASM library discovered the same disk
-- prompt ...            Oracle ASM has determined that the membership claimed by the disk header is no longer valid
-- prompt ... CLOSING - Oracle ASM is in the process of closing this disk
--  
--  
--  
-- prompt ... 
-- prompt ... Header status of the disk :
-- prompt ... 
-- prompt ... UNKNOWN - Oracle ASM disk header has not been read
-- prompt ... CANDIDATE - Disk is not part of a disk group and may be added to a disk group with the ALTER DISKGROUP statement
-- prompt ... INCOMPATIBLE - Version number in the disk header is not compatible with the Oracle ASM software version
-- prompt ... PROVISIONED - Disk is not part of a disk group and may be added to a disk group with the ALTER DISKGROUP statement. The PROVISIONED header status is different from the CANDIDATE header status in that PROVISIONED implies that an additional platform-specific action has been taken by an administrator to make the disk available for Oracle ASM.
-- prompt ... MEMBER - Disk is a member of an existing disk group. No attempt should be made to add the disk to a different disk group. The ALTER DISKGROUP statement will reject such an addition unless overridden with the FORCE option.
-- prompt ... FORMER - Disk was once part of a disk group but has been dropped cleanly from the group. It may be added to a new disk group with the ALTER DISKGROUP statement.
-- prompt ... CONFLICT - Oracle ASM disk was not mounted due to a conflict
-- prompt ... FOREIGN - Disk contains data created by an Oracle product other than ASM. This includes datafiles, logfiles, and OCR disks.

 
prompt ... 
prompt ... State of the disk :
prompt ... 
prompt ... UNKNOWN  - Oracle ASM disk state is not known (typically the disk is not mounted)
prompt ... NORMAL   - Disk is online and operating normally
prompt ... ADDING   - Disk is being added to a disk group, 
prompt ...            and is pending validation by all instances that have the disk group mounted
prompt ... DROPPING - Disk has been manually taken offline and space allocation or data access for the disk halts. 
prompt ...            Rebalancing will commence to relocate data off the disks to other disks in the disk group. 
prompt ... 		      Upon completion of the rebalance, the disk is expelled from the group.
prompt ... HUNG -     Disk drop operation cannot continue because there is insufficient space 
prompt ...            to relocate the data from the disk being dropped
prompt ... FORCING -  Disk is being removed from the disk group without attempting to offload its data. 
prompt ...            The data will be recovered from redundant copies, where possible.
prompt ... DROPPED -  Disk has been fully expelled from the disk group
 
 
 
ttitle left  "Size  all groups" skip 2

column disk_count_online format 9999 heading "Disk|on"
column disk_count_offine format 9999 heading "Disk|off"

select  g.group_number
      , g.name
      , g.state
      , g.type
      , g.total_mb  Brutto
	  , decode(g.type,'NORMAL',g.total_mb/2,g.total_mb) Netto
      , g.usable_file_mb as free_netto
	  , case when g.state !='DISMOUNTED' then
				to_char(round(g.usable_file_mb/(decode(type,'NORMAL',g.total_mb/2,g.total_mb)/100),2),'00D99')
		   else 'n/a'			
		 end as free_percent
	  , (select count(*) from v$asm_disk i where i.group_number=g.group_number and VOTING_FILE='Y')  as disk_count_vot	  	 
	  , (select count(*) from v$asm_disk i where i.group_number=g.group_number and i.mode_status='ONLINE') as disk_count_online
	  , (select count(*) from v$asm_disk i where i.group_number=g.group_number and i.mode_status!='ONLINE') as disk_count_offine	
  from v$asm_diskgroup g
order by g.name  
/

--

prompt ... 
prompt ... State of the disk group:
prompt ... 
prompt ... CONNECTED  - Disk group is in use by the database instance
prompt ... BROKEN     - Database instance lost connectivity to the Automatic Storage Management instance that mounted the disk group
prompt ... UNKNOWN    - Automatic Storage Management instance has never attempted to mount the disk group
prompt ... DISMOUNTED - Disk group was cleanly dismounted by the Automatic Storage Management instance following a successful mount
prompt ... MOUNTED    - Instance is successfully serving the disk group to its database clients
prompt ... QUIESCING  - CRSCTL utility attempted to dismount a disk group that contains the Oracle Cluster Registry (OCR).
prompt ... 
--

ttitle left  "Check ASM Disk Size and Usage over all groups" skip 2

column Brutto   format 999G999G999 heading "Size per|Disk MB" 
column d_cnt    format 999         heading "Count|Disk" 
column max_used format 999G999G999 heading "Max per Disk|Used MB"
column min_used format 999G999G999 heading "Min per Disk|Used MB"
column oem_metric_imblance format 90D00 heading "OEM Disk|Imbalance"

select  g.group_number
      , g.name     
      , d.total_mb Brutto
      , max(d.total_mb-d.free_mb + (128*g.allocation_unit_size/1048576)) max_used
      , min(d.total_mb-d.free_mb + (128*g.allocation_unit_size/1048576)) min_used    
	  , count(d.DISK_NUMBER ) as d_cnt		
	  , round(100*(max((d.total_mb-d.free_mb + (128*g.allocation_unit_size/1048576))/(d.total_mb + (128*g.allocation_unit_size/1048576)))-min((d.total_mb-d.free_mb + (128*g.allocation_unit_size/1048576))/(d.total_mb + (128*g.allocation_unit_size/1048576))))/max((d.total_mb-d.free_mb + (128*g.allocation_unit_size/1048576))/(d.total_mb + (128*g.allocation_unit_size/1048576))),2) as oem_metric_imblance
from     v$asm_disk_stat d
        ,v$asm_diskgroup_stat g
        ,v$asm_operation op		 
where  d.group_number = g.group_number 
  and  g.group_number = op.group_number(+) 
  and  d.group_number <> 0 
  and  d.state = 'NORMAL' 
  and  d.mount_status = 'CACHED'  
group by g.group_number,g.name,d.total_mb 
order by g.name,d.total_mb 
/

prompt ...
prompt ... if Max per Disk|Used MB and Min per Disk|Used MB are very different you may be need a "alter diskgroup xxxx rebalance power 5"
prompt ...

ttitle off






