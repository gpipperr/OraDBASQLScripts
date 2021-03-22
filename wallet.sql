--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  get the Wallet Settings of the DB
--
-- Must be run with dba privileges
-- Source see Step by Step Troubleshooting Guide for TDE Error ORA-28374 (Doc ID 1541818.1)
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "The Path to the Wallet" skip 2 


column WRL_TYPE      format a10 heading "WRL|Type"
column WRL_PARAMETER format a20 heading "Wallet|Params"
column STATUS        format a10 heading "Status"
column WALLET_TYPE  format a10 heading "Wallet|type"
column WALLET_ORDER  format a9 heading "Status"
column FULLY_BACKED_UP  format a9 heading "Backup"
column CON_ID  format 999 heading "Con|ID"
column inst_id format 999 heading "Inst|ID"


select 	inst_id
        , WRL_TYPE
		,WRL_PARAMETER
		,STATUS
		,WALLET_TYPE
		,WALLET_ORDER
		,FULLY_BACKED_UP
		,CON_ID
from gv$encryption_wallet
/


ttitle left  "Get the Master Keys " skip 2 
column key_id format a60
select key_id
      ,to_char(activation_time,'dd.mm.yyyy hh24:mi') as activation_time
 from v$encryption_keys
/


column name format a40
column masterkeyid_base64 format a60

ttitle left  "Get the Master Key for Tablespaces" skip 2 

select  name
       ,utl_raw.cast_to_varchar2( utl_encode.base64_encode('01'||substr(mkeyid,1,4))) || utl_raw.cast_to_varchar2( utl_encode.base64_encode(substr(mkeyid,5,length(mkeyid)))) masterkeyid_base64  
  FROM (select t.name, RAWTOHEX(x.mkid) mkeyid 
          from v$tablespace t
		     , x$kcbtek x 
		 where t.ts#=x.ts#)
/		 


ttitle left  "Get the Master Key for the Controlfile" skip 2 

select  utl_raw.cast_to_varchar2( utl_encode.base64_encode('01'||substr(mkeyid,1,4))) || utl_raw.cast_to_varchar2( utl_encode.base64_encode(substr(mkeyid,5,length(mkeyid)))) masterkeyid_base64  
  FROM (select RAWTOHEX(mkid) mkeyid 
          from x$kcbdbk)
/		  


ttitle left  "Get the Master Key for Tables" skip 2 

select mkeyid from enc$;


ttitle left  "Witch Columns are encrypted?" skip 2 

column owner          format a15  heading "Owner"
column table_name     format a15  heading "Table|Name"
column column_name    format a15 heading "Column|Name"
column ENCRYPTION_ALG format a35 heading "Encryption|Algo"

select owner          
	,table_name     
	,column_name    
	,ENCRYPTION_ALG 
from dba_encrypted_columns
/

ttitle off