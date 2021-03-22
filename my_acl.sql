--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show my rights
--==============================================================================
--http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_networkacl_adm.htm#CHDJFJFF
--http://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/acl/index.html
--http://www.oracleflash.com/36/Oracle-11g-Access-Control-List-for-External-Network-Services.html
--http://www.oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1.php
--==============================================================================
set linesize 130 pagesize 300 

column acl       format a40 heading "ACL"
column host      format a16 
column principal format a16
column privilege format a10
column is_grant  format a8
column lower_port format a12 heading "Lower Port"
column upper_port format a12 heading "Upper Port"

set lines 1000

SELECT host
     , to_char(lower_port) lower_port
	 , to_char(upper_port) upper_port
	 , privilege
	 , status
FROM user_network_acl_privileges
/

prompt ... to check if your pattern match use this function 
prompt ... select * from table(dbms_network_acl_utility.domains('<my-ip or name>'));