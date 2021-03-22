-- ====================================================================
-- GPI - Gunther Pippèrr 
-- get Information about the partner disk if redundancy is <> external
--
-- ====================================================================
-- see also:
-- http://asmsupportguy.blogspot.de/2011/07/how-many-partners.html
-- http://afatkulin.blogspot.de/2010/07/asm-mirroring-and-disk-partnership.html
-- Script to Report the Percentage of Imbalance in all Mounted Diskgroups (Doc ID 367445.1)
--==============================================================================

set linesize 130 pagesize 300 
set verify  off

prompt
prompt Parameter 1 = DISK_GROUP_NR          => '&1' 
prompt

define DISK_GROUP_NR = '&1' 

ttitle left  "Check for Imbalance over all disks" skip 2

select min(cnt), max(cnt),grp 
  from (select number_kfdpartner disk_number
             , count(*) cnt
				 , grp   
		  from x$kfdpartner  
		 group by number_kfdpartner,grp)
group by grp
/  

-- from the OEM Metric for Imbalance

ttitle left  "Check for OEM Metric for Imbalance over all disks of the group &&DISK_GROUP_NR." skip 2

select x.grp grp
       ,  x.disk disk
       ,  sum (x.active) cnt
       ,  greatest (sum (  x.total_mb / d.total_mb),0.0001)  pspace
       ,  x.total_mb
       ,  d.total_mb
       ,  d.failgroup fgrp
    from v$asm_disk_stat d
       ,  (select y.grp grp
                ,  y.disk disk
                ,  z.total_mb  * y.active_kfdpartner  total_mb
                ,  y.active_kfdpartner active
             from x$kfdpartner y, v$asm_disk_stat z
            where     y.number_kfdpartner = z.disk_number
                  and y.grp = z.group_number
                  and y.grp = &&DISK_GROUP_NR.) x
   where d.group_number = x.grp
     and d.disk_number = x.disk
     and d.group_number <> 0
     and d.state = 'NORMAL'
     and d.mount_status = 'CACHED'
group by x.grp
       ,  x.disk
       ,  d.failgroup
       ,  x.total_mb
       ,  d.total_mb
/


ttitle off