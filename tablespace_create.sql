--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the ddl example for a new tablespace
--       Parameter name of the tablespace
--       Path of the datafiles
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define TABLESPACE_NAME = '&1' 
define DATA_FILE_PATH  = '&2' 

prompt
prompt Parameter 1 = Tablespace Name => &&TABLESPACE_NAME.
prompt Parameter 1 = Data File Path  => &&DATA_FILE_PATH.
prompt
prompt  Example DDL to create a tablespace
prompt 
prompt CREATE TABLESPACE &&TABLESPACE_NAME. DATAFILE   
prompt     '&&DATA_FILE_PATH.&&TABLESPACE_NAME.01.DBF' SIZE 100M  AUTOEXTEND ON NEXT 10M MAXSIZE 32000M
prompt    ,'&&DATA_FILE_PATH.&&TABLESPACE_NAME.02.DBF' SIZE 100M  AUTOEXTEND ON NEXT 10M MAXSIZE 32000M
prompt   LOGGING 
prompt   ONLINE 
prompt   PERMANENT 
--prompt   BLOCKSIZE 8192
prompt   EXTENT MANAGEMENT LOCAL UNIFORM SIZE 10M 
prompt   DEFAULT NOCOMPRESS  
prompt   SEGMENT SPACE MANAGEMENT AUTO
prompt 
prompt 