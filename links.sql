--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   DB Links
-- Date:   01.September 2012
--
--==============================================================================
set linesize 130 pagesize 300 

set verify off

define LINKHOST = &1 

variable PLINKHOST varchar2(32)

prompt
prompt Parameter 1 = Link Host => &&LINKHOST.
prompt

begin
 if length('&&LINKHOST.') < 1 then
   :PLINKHOST:='%';
 else
   :PLINKHOST:='&&LINKHOST.'||'%';
 end if;
end;
/



prompt
prompt Link Infos -- The DB Links this user can see
prompt 

column owner format a20
column host  format a40
column db_link format a25
column username format a20


select db_link
      , host
	  , owner 
	  , username
 from all_db_links 
where lower(host) like lower(:PLINKHOST)
 /


ttitle left  "Link Infos -- All DB Links in the database" skip 2

select db_link
	  , owner 
	  , host
	  , username
 from dba_db_links 
where lower(host) like lower(:PLINKHOST)
 /

 


prompt ...
prompt ... to create a private db link use this statement:
prompt ... "CREATE DATABASE LINK mylink CONNECT TO remote_user IDENTIFIED BY remote_pwd USING 'remote_db';"
prompt ... to get the DDL of all links use links_ddl.sql
prompt ...

--see http://docs.oracle.com/cd/B28359_01/server.111/b28310/ds_admin005.htm


ttitle left  "DB Links in Use now in the database" skip 2


column DB_LINK 			format A25
column OWNER_ID 		format 99999 HEADING "OWNID"
column LOGGED_ON 		format A5 HEADING "LOGON"
column HETEROGENEOUS 	format A5 HEADING "HETER"
column PROTOCOL 		format A8
column OPEN_CURSORS 	format 999 HEADING "OPN_CUR"
column IN_TRANSACTION 	format A3 HEADING "TXN"
column UPDATE_SENT 		format A6 HEADING "UPDATE"
column COMMIT_POINT_STRENGTH format 99999 HEADING "C_P_S"

SELECT * FROM V$DBLINK
/

ttitle off

--undef variables ---

undefine PUSERNAME 

---------------------
set verify on
