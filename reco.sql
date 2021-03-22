--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Recovery Area settings and size
-- Date:   01.September 2012
--
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report Recovery Dest Parameter"  SKIP 1 -
       center "Sizes in MB" SKIP 2

archive log list
	   
show parameter reco

column limit            format a14
column used             format a14
column reclaimable      format a14
column number_of_files  format a6 heading "Files"
column used             format a12
	   
select to_char(round(SPACE_LIMIT / 1024 / 1024, 2)) || ' M Limit' as limit
      ,to_char(round(SPACE_USED / 1024 / 1024, 2)) || ' M in Use' as used
      ,to_char(round(SPACE_RECLAIMABLE / 1024 / 1024, 2)) || ' M' as RECLAIMABLE
      ,to_char(NUMBER_OF_FILES) as NUMBER_OF_FILES
      ,to_char(round((SPACE_USED * 100) / SPACE_LIMIT, 2), '909D00')||' %' as Used
  from V$RECOVERY_FILE_DEST
/

ttitle  "Report if Archvelogs can be deleted"  SKIP 1 -

SELECT  applied
      , deleted
	  , decode(rectype,11,'YES','NO') AS reclaimable
      , COUNT(*)
	  , MIN(SEQUENCE#)
	  , MAX(SEQUENCE#)
 FROM v$archived_log LEFT OUTER JOIN sys.x$kccagf USING(recid) 
WHERE is_recovery_dest_file='YES' AND name IS NOT NULL
GROUP BY applied,deleted,decode(rectype,11,'YES','NO') ORDER BY 5
/

prompt ... rman setting see CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;

ttitle off
