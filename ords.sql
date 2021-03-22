--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc: get the ORDS REST data service settings
-- Date: 03.2017
--==============================================================================
-- Source:
--https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-create-basic-rest-web-services-using-plsql
--==============================================================================

set linesize 130 pagesize 300 

column source_type   format a15
column source        format a35
column uri_template  format a20
column name          format a20
column uri_prefix    format a20
column method        format a10
column id            format 9999999

ttitle left  "ORDS Modules" skip 2

select id
     , name
	 , uri_prefix
 from  user_ords_modules
order by name
/
 
ttitle left  "ORDS Templates" skip 2  
select id
     , module_id
	 , uri_template
from user_ords_templates
order by module_id
/
 

ttitle left  "ORDS Handlers" skip 2  
select id
     , template_id
	 , source_type
	 , method, source
from  user_ords_handlers
order by id
/

ttitle off