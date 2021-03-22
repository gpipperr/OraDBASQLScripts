--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   overview over the datafile of the database
-- Date:   01.September 2012
--
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report Database Files"  SKIP 1 -
       center "Sizes in MB" SKIP 2

column tablespace_name format a18 heading "Tablespace"
column df_size format 999999 heading "Size"
column F_ID format 999
column FILE_NAME format A53 heading "Filename"
column status format A10
column fragidx format A12 heading "Fragmen. Index"

select FILE_ID as F_ID
      ,round((BYTES / 1024 / 1024)) as df_size
      ,TABLESPACE_NAME
      ,FILE_NAME
      ,ONLINE_STATUS as status
  from dba_data_files
 order by TABLESPACE_NAME
         ,FILE_NAME
/

ttitle  "Report Temp Files"  SKIP 2

select FILE_ID as F_ID
      ,round((BYTES / 1024 / 1024)) as df_size
      ,TABLESPACE_NAME
      ,FILE_NAME
      ,STATUS as status
  from dba_temp_files
 order by TABLESPACE_NAME
         ,FILE_NAME
/

ttitle  "Usage of the datafiles"  SKIP 2

select d.file_name 
       ,ROUND(max(d.BYTES) / 1024 / 1024, 2) "total MB"
       ,DECODE(sum(f.BYTES), null, 0, ROUND(sum(f.BYTES) / 1024 / 1024, 2)) "Free MB"
       ,DECODE(sum(f.BYTES), null, 0, ROUND((max(d.BYTES) / 1024 / 1024) - (sum(f.BYTES) / 1024 / 1024), 2)) "Used MB"
       --,         ROUND (MAX (d.BYTES) / 1024, 2) "total KB"
       --,         DECODE (SUM (f.BYTES),
       --                NULL, 0,
       --                 ROUND (SUM (f.BYTES) / 1024, 2)
       --                ) "Free KB"
       --,      DECODE (SUM (f.BYTES),
       --                 NULL, 0,
       --                 ROUND ((MAX (d.BYTES) / 1024) - (SUM (f.BYTES) / 1024), 2)
       --                ) "Used KB"
       ,to_char(ROUND(SQRT(max(f.blocks) / sum(f.blocks)) * (100 / SQRT(SQRT(count(f.blocks)))), 2), '999D00') as fragidx
  from dba_free_space f
      ,dba_data_files d
 where f.tablespace_name(+) = d.tablespace_name
   and f.file_id(+) = d.file_id
 group by d.file_name 
 /

 ttitle  "I/O performance of the datafiles"  SKIP 2
 
 
column phyrds    format 999G999G999 heading "Physical|Reads"
column phywrts   format 999G999G999 heading "Physical|Writes"
column max_readtime   format 999D999 heading "Max Read|Time"
column max_writetime  format 999D999 heading "Max Write|Time"
column avg_iotime     format 999D999 heading "AVG IO|Time"
column file_name format a25 heading "File|Name"

select substr(b.name,length(b.name)-REGEXP_INSTR(reverse(b.name),'[\/|\]')+2,1000) as file_name
     , a.phyrds
	 , a.MAXIORTM/100 as max_readtime
	 , a.phywrts
	 , a.MAXIOWTM/100 as max_writetime
	 , AVGIOTIM/100   as avg_iotime
from v$filestat a
   , v$dbfile b
where a.file# = b.file#
order by b.name
/
 
ttitle off

prompt ...
prompt ... to add a datafile you can use this example
prompt ... "ALTER TABLESPACE <NAME> ADD DATAFILE '<path>/<name>.dbf' SIZE 10M  AUTOEXTEND ON NEXT 10M  MAXSIZE 3000M;"
prompt ...
