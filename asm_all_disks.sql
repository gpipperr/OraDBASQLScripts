--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc:   show asm candidate disks
-- Date:   November 2013
--==============================================================================
set linesize 130 pagesize 300 

column OS_MB format 9G999G999 heading "OS|MB"  

column name  format a16 heading "Disk|Name"
column path  format a40 heading "Disk|Path" 
column header_status format a10 heading "Header|status" 
column mount_status  format a10 heading "Mount|status" 
column mode_status   format a10 heading "Mode|status" 
column state         format a10 heading "State" 
column GROUP_NUMBER  format 999 heading "Grp|Nr"

ttitle left  "ASM Disk Candidates" skip 2



SELECT GROUP_NUMBER
     , path
	 , name
	 , OS_MB
	 , header_status
	 , mount_status
	 , mode_status
	 , state 
 FROM v$asm_disk 
ORDER BY GROUP_NUMBER
/


prompt ----------------------

ttitle left "ASM Disks Size "

select  d.GROUP_NUMBER 
      , g.name
      , d.name 
      --, d.path
      , d.TOTAL_MB 
      , d.FREE_MB 
      , d.total_mb - d.free_mb as used 
  from  v$asm_disk  d 
     ,  v$asm_diskgroup g 
where g.GROUP_NUMBER (+) = d.GROUP_NUMBER	   
order by 1   
/

ttitle off