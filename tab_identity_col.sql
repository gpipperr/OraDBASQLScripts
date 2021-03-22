--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get informations about identiy columns in tables
--==============================================================================
-- https://oracle-base.com/articles/12c/identity-columns-in-oracle-12cr1
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.


COLUMN table_name      FORMAT A20
COLUMN column_name     FORMAT A15
COLUMN generation_type  FORMAT A10
COLUMN identity_options FORMAT A50
COLUMN sequence_name    FORMAT A30


SELECT table_name, 
       column_name,
       generation_type,
       identity_options
FROM   dba_tab_identity_cols
/

SELECT a.name AS table_name,
       b.name AS sequence_name
FROM   sys.idnseq$ c
       JOIN obj$ a ON c.obj# = a.obj#
       JOIN obj$ b ON c.seqobj# = b.obj#
/
