--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the xml DB Configuration
-- Date:   November 2013
--==============================================================================
set linesize 130 pagesize 4000 

ttitle  "XML DB Configuration"  SKIP 2

set long 100000

select dbms_xdb.cfg_get from dual
/

ttitle off
