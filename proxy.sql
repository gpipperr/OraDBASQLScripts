--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the proxy user settings
-- Date:   Oktober 2013
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 

prompt
prompt Parameter 1 = User Name      => &&USER_NAME.
prompt

ttitle left  "Proxy Settings for this database" skip 2

column proxy                    format a15 heading "Proxy"
column client                   format a15 heading "Client|User"
column authentication           format a5  heading "Auth"
column authorization_constraint format a40 heading "Auth|Const"
column role                     format a15 heading "Role"
column proxy_authority          format a10 heading "Proxy|Auth"

select 	proxy
	, client
	, authentication
	, authorization_constraint
	, role
	, proxy_authority
 from dba_proxies
where proxy like upper('&&USER_NAME.')	
order by 1
/

ttitle off
