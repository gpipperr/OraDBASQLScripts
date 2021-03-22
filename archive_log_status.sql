-- ======================================================
-- GPI - Gunther Pippèrr
-- Desc : Check the status of the archive logs 
-- ======================================================

-- archive_log_status.sql
-- see https://blog.dbi-services.com/archivelog-deletion-policy-for-standby-database-in-oracle-data-guard/

set verify off
set linesize 130 pagesize 300 

set serveroutput on size 1000000


prompt ... Check if archivelogs are need for recovery or can be deleted

select  applied
      , deleted
	  , decode(rectype,11,'YES','NO') as reclaimable
      , count(*)
	  , min(sequence#)
	  , max(sequence#)
 from v$archived_log left outer join sys.x$kccagf using(recid) 
where is_recovery_dest_file='YES' and name is not null
group by applied,deleted,decode(rectype,11,'YES','NO') order by 5
/

prompt ... 
prompt ... reclaimable = YES means that this archivelog can be deleted and is not nesseary anymore for the recovery, maybe still backuped
prompt ... set with RMAN "CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;" to trigger check of archivelogs
prompt ... 