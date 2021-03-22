--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   SQL Script to shrink the tablespace
-- Doku:   http://www.pipperr.de/dokuwiki/doku.php?id=dba:sql_groesse_tabelle
-- Date:   08.2013
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set feedback OFF
set heading OFF
set trimspool on

---------------------------------------
-- create the spool file
col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_shrink_database.sql','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/
---------------------------------------

spool &&SPOOL_NAME

prompt spool &&SPOOL_NAME._log

---------------------------------------
-- create the alter script
--
column command format a100

select '-- Info -- try to free:: '||round((s.bytes - e.max_data_block_id * et.BLOCK_SIZE) / 1024 / 1024,3) ||' MB'||chr(13)||chr(10)||'alter database datafile ' ||chr(13)||chr(10)||''''||s.file_name||''''||chr(13)||chr(10)||'resize ' ||round(e.max_data_block_id * et.BLOCK_SIZE / 1024 / 1024 + 1, 0) || 'M;'  as command
 from dba_data_files s
      , (select file_id
              ,max(block_id + blocks) + 1 max_data_block_id
			  ,tablespace_name
          from dba_extents		
		  group by file_id,tablespace_name) e
	 , dba_tablespaces et	 
 where s.FILE_ID = e.file_id
   and s.TABLESPACE_NAME = et.TABLESPACE_NAME
   and e.TABLESPACE_NAME =et.TABLESPACE_NAME  
   and (s.bytes - e.max_data_block_id * et.BLOCK_SIZE) / 1024 / 1024 > 10
/
---------------------------------------

prompt spool off

spool off
---------------------------------------
-- call the script
@&&SPOOL_NAME
---------------------------------------
 
set verify    ON
set feedback  ON
set heading   ON
set trimspool OFF
set recsep    WRAP
 
 
 
 