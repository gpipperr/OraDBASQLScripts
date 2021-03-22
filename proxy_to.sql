--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   All schemas that can be switch to this schema with proxy rights - parameter 1 name of the schema
-- Date:   March 2018
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 

prompt
prompt Parameter 1 = Schema Name      => &&USER_NAME.
prompt

ttitle left  "How can switch to this schema with Proxy rights" skip 2

column proxy                    format a15 heading "Proxy"
column client                   format a15 heading "Schema|User"
column authentication           format a5  heading "Auth"
column authorization_constraint format a40 heading "Auth|Const"
column role                     format a15 heading "Role"
column proxy_authority          format a10 heading "Proxy|Auth"

select client
	,  proxy
	,  authentication
	,  authorization_constraint
	,  role
	,  proxy_authority
 from dba_proxies
where client like upper('&&USER_NAME.')	
order by 1
/

ttitle off
