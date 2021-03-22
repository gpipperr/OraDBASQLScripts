--===============================================================================
-- GPI - Gunther Pippèrr
--http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_networkacl_adm.htm#CHDJFJFF
--http://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/acl/index.html
--http://www.oracleflash.com/36/Oracle-11g-Access-Control-List-for-External-Network-Services.html
--http://www.oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1.php
--===============================================================================

set linesize 130 pagesize 300 

column acl       format a40 heading "ACL"
column host      format a30
column principal format a16
column privilege format a10
column is_grant  format a8
column lower_port format a12 heading "Lower Port"
column upper_port format a12 heading "Upper Port"

set lines 1000

select acl
     ,  host
     ,  to_char (lower_port) lower_port
     ,  to_char (upper_port) upper_port
  from DBA_NETWORK_ACLS
/

select acl
     ,  principal
     ,  privilege
     ,  is_grant
  from DBA_NETWORK_ACL_PRIVILEGES
/


-- from https://docs.oracle.com/database/121/ARPLS/d_networkacl_adm.htm#ARPLS67214
select host
       , lower_port
	   , upper_port
	   , ace_order
	   , principal
	   , principal_type
	   , grant_type
	   , inverted_principal
	   , privilege
	   , start_date
	   , end_date
  from (select aces.*,
dbms_network_acl_utility.contains_host('*',
                                                      host) precedence
          from dba_host_aces aces)
 where precedence is not null
 order by precedence desc,
          lower_port nulls last,
          upper_port nulls last,
          ace_order;
/
/*
 test entry:
 
 BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'my_test_acl.xml', 
    description  => 'A test of the ACL functionality',
    principal    => 'GPI',
    is_grant     => TRUE, 
    privilege    => 'connect');   
     
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
        acl       => 'my_test_acl.xml',
      principal => 'GPI',
      is_grant  => true,
      privilege => 'resolve');
        
  COMMIT;
END;
/

begin
-- the I can all
 DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'my_test_acl.xml',
    host        => '*', 
    lower_port  => 1,
    upper_port  => 9999); 

-- ony one server     
 DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(
    acl  => 'my_test_acl.xml',
   host => 'www-proxy.us.oracle.com');

COMMIT;

end;
/     

-- delete one acl
begin
 DBMS_NETWORK_ACL_ADMIN.UNASSIGN_ACL (
     acl         => 'localhost-permissions.xml',
    host        => 'pbupcb1.pbprd.lprz.com', 
    lower_port  => 9080,     
    upper_port  => 9080)
     ; 
end;
/        

declare
   l_url   varchar2 (50)
      := 'http://www.goggle.de;
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(l_url);
  l_http_response := UTL_HTTP.get_response(l_http_request);  
  UTL_HTTP.end_response(l_http_response);
END;
/


*/