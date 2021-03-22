--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the users of the database
-- Date:   November 2017
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 


column CURRENT_USER    format a14 heading "CURRENT|USER"
column CURRENT_USERID  format a14 heading "CURRENT|USERID"
column PROXY_USER      format a14 heading "PROXY|USER"
column PROXY_USERID    format a14 heading "PROXY|USERID"
column AUTH_IDENT      format a20 heading "AUTH|IDENT"

ttitle left  "My akct Identity" skip 2

SELECT SYS_CONTEXT ('USERENV', 'CURRENT_USER')   CURRENT_USER
     , SYS_CONTEXT ('USERENV', 'CURRENT_USERID') CURRENT_USERID
	 , SYS_CONTEXT ('USERENV', 'PROXY_USER')     PROXY_USER
	 , SYS_CONTEXT ('USERENV', 'PROXY_USERID')   PROXY_USERID
	 , SYS_CONTEXT ('USERENV', 'AUTHENTICATED_IDENTITY') AUTH_IDENT
FROM DUAL
/

ttitle left  "To which users I can proxy" skip 2


column proxy                    format a15 heading "Proxy"
column client                   format a15 heading "Client|User"
column authentication           format a5  heading "Auth"
column authorization_constraint format a40 heading "Auth|Const"
column role                     format a15 heading "Role"

select 	CLIENT
      , AUTHENTICATION
      , AUTHORIZATION_CONSTRAINT
      , ROLE
 from USER_PROXIES
order by 1
/

 

ttitle off

