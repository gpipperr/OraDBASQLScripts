--==============================================================================
-- GPI - Gunther Pippèrr
-- get Information about the installed java options and security settings
--==============================================================================
set linesize 130 pagesize 4000 

column KIND     
column GRANTEE     format a15 
column TYPE_SCHEMA format a10  heading "Type|Schema"
column TYPE_NAME   format a25  heading "Type|Name"
column NAME        format a25  heading "Name"
column ACTION      format a25
column ENABLED     format a10
column SEQ         format 9999

ttitle  "Java Access Rights"  SKIP 2

select KIND
	,	GRANTEE
	,	TYPE_SCHEMA
	,	TYPE_NAME
	,	NAME
	,	ACTION
	,	ENABLED
	,	SEQ
from DBA_JAVA_POLICY 
where GRANTEE != 'SYS'
order by SEQ
/

ttitle off
