--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the profiles of the database
-- Date:   September 2013
-- see http://docs.oracle.com/cd/B28359_01/network.111/b28531/vpd.htm
--==============================================================================
-- see
-- DBA_POLICIES          Describes all Oracle Virtual Private Database security policies in the database.
-- DBA_POLICY_GROUPS     Describes all policy groups in the database.
-- DBA_POLICY_CONTEXTS   Describes all driving contexts in the database. Its columns are the same as those in ALL_POLICY_CONTEXTS.
-- DBA_SEC_RELEVANT_COLS Describes the security relevant columns of all security policies in the database

set linesize 130 pagesize 300 

ttitle  "VPD Informations"  SKIP 2

column OBJECT_OWNER   format a10   heading "OBJECT|OWNER"   
column OBJECT_NAME    format a15   heading "OBJECT|NAME "   
column POLICY_GROUP   format a15   heading "POLICY|GROUP"   
column POLICY_NAME    format a15   heading "POLICY|NAME "   
column PF_OWNER       format a7   heading "PF|OWNER"   
column PACKAGE        format a15   heading "PACKAGE"   
column FUNCTION       format a15    heading "FUNCTION"   
column SEL            format a3    heading "SEL"   
column INS            format a3    heading "INS"   
column UPD            format a3    heading "UPD"   
column DEL            format a3    heading "DEL"   
column IDX            format a3    heading "IDX"   
column CHK_OPTION     format a3    heading "CHK|OPTION"   
column ENABLE         format a3    heading "ENABLE"   
column STATIC_POLICY  format a3    heading "STATIC|POLICY"  
column POLICY_TYPE    format a20   heading "POLICY|TYPE"    
column LONG_PREDICATE format a3    heading "LONG|PREDICATE" 


select  OBJECT_OWNER
	,	OBJECT_NAME 
	,	POLICY_GROUP
	,	POLICY_NAME 
	,	PF_OWNER    
	,	PACKAGE     
	,	FUNCTION
	,	ENABLE
from DBA_POLICIES
/


ttitle off