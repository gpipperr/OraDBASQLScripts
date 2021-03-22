--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Query the audit log entries
--
-- Must be run with dba privileges
--
--==============================================================================
set linesize 130 pagesize 300 

select dbms_xdb.gethttpport as "HTTP-Port"
     , dbms_xdb_config.getHttpsPort() as "HTTPS-Port"
     , dbms_xdb.getftpport as "FTP-Port" 
  from dual
 /
 
 