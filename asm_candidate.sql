--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc:   show asm candidate disks
-- Date:   November 2013
--==============================================================================
set linesize 130 pagesize 300 


column OS_MB format 9999999 heading "OS|MB"  

column name  format a20 heading "Disk|Name"
column path  format a30 heading "Disk|Path" 
column header_status format a15 heading "header|status" 
column mount_status  format a15 heading "mount|status" 
column mode_status   format a15 heading "mode|status" 
column state         format a15 heading "state" 

ttitle left  "ASM Disk Candidates" skip 2

SELECT OS_MB 
     , DISK_NUMBER
	 , path 
	 , header_status
     , mount_status
     , mode_status
     , state
 FROM v$asm_disk 
WHERE GROUP_NUMBER=0
order by header_status;

prompt ... 
prompt ... Header status of the disk :
prompt ... 
prompt ... UNKNOWN      - Oracle ASM disk header has not been read
prompt ... CANDIDATE    - Disk is not part of a disk group and may be added to a disk group with the ALTER DISKGROUP statement
prompt ... INCOMPATIBLE - Version number in the disk header is not compatible with the Oracle ASM software version
prompt ... PROVISIONED  - Disk is not part of a disk group and may be added to a disk group with the ALTER DISKGROUP statement. 
prompt ... MEMBER       - Disk is a member of an existing disk group. No attempt should be made to add the disk to a different disk group. 
prompt ...                The ALTER DISKGROUP statement will reject such an addition unless overridden with the FORCE option.
prompt ... FORMER       - Disk was once part of a disk group but has been dropped cleanly from the group. 
prompt ... CONFLICT     - Oracle ASM disk was not mounted due to a conflict
prompt ... FOREIGN      - Disk contains data created by an Oracle product other than ASM


ttitle off
