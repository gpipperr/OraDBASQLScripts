-- GPI - Gunther Pippèrr
-- Desc:   overview over a container database 
-- Date:   25.October 2018
-- => https://docs.oracle.com/database/121/ADMIN/cdb_mon.htm#ADMIN13939
--==============================================================================
set linesize 130 pagesize 300 


SHOW CON_NAME


-- check if CDB
SELECT CDB FROM V$DATABASE;

-- get all pugbale databases
SELECT NAME, CON_ID, DBID, CON_UID, GUID FROM V$CONTAINERS ORDER BY CON_ID;

COLUMN PDB_NAME FORMAT A15
 
SELECT PDB_ID, PDB_NAME, STATUS FROM DBA_PDBS ORDER BY PDB_ID;

-- open MODE
COLUMN NAME FORMAT A15
COLUMN RESTRICTED FORMAT A10
COLUMN OPEN_TIME FORMAT A30
 
SELECT NAME, OPEN_MODE, RESTRICTED, OPEN_TIME FROM V$PDBS;

--Showing the Data Files for Each PDB in a CDB
COLUMN PDB_ID FORMAT 999
COLUMN PDB_NAME FORMAT A8
COLUMN FILE_ID FORMAT 9999
COLUMN TABLESPACE_NAME FORMAT A10
COLUMN FILE_NAME FORMAT A45

SELECT p.PDB_ID, p.PDB_NAME, d.FILE_ID, d.TABLESPACE_NAME, d.FILE_NAME
  FROM DBA_PDBS p, CDB_DATA_FILES d
  WHERE p.PDB_ID = d.CON_ID
  ORDER BY p.PDB_ID;