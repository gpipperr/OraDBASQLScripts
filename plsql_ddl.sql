--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  spool a pl/sql object 
-- Must be run with dba privileges
--==============================================================================
set verify  off
set linesize 300 pagesize 4000 
set trimspool on

define OWNER        = '&1'
define PACKAGE_NAME = '&2'

prompt
prompt Parameter 1 = Owner   Name   => &&OWNER.
prompt Parameter 2 = Package Name   => &&PACKAGE_NAME.
prompt

col SPOOL_NAME_COL new_val SPOOL_NAME

select replace (ora_database_name || '_' || to_char (sysdate, 'dd_mm_yyyy_hh24_mi') || '_&&OWNER._&&PACKAGE_NAME..sql', '\', '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/

variable ddllob clob

set heading off
set echo off

set long 1000000;

declare
   cursor c_tab_obj
   is
        select object_name, replace (object_type, ' ', '_') as object_type, owner
          from dba_objects
         where     object_name = upper ('&&PACKAGE_NAME.')
               and OWNER = upper ('&&OWNER.')
      order by object_type;
begin
-- set the transformation attributes
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY',             true );
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR',      true );
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',    false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'OID',                false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE',         true );

   --
   :ddllob := '-- create the  DLL for the Object &&OWNER..&&PACKAGE_NAME.';

   -- get the DDL for this object
   for rec in c_tab_obj
   loop
      :ddllob := :ddllob || chr (10) || chr (10) || '-- DDL for Object : ' || rec.object_name || chr (10);
      :ddllob := :ddllob || dbms_metadata.get_ddl (rec.object_type, rec.object_name, rec.owner);
   end loop;

   :ddllob := :ddllob || chr (10) || chr (10) || '-- DDL for Grants : ' || chr (10);

   begin
      :ddllob := :ddllob || dbms_metadata.GET_DEPENDENT_DDL ('OBJECT_GRANT', upper ('&&PACKAGE_NAME.'), upper ('&&OWNER.'));
   exception
      when others
      then
         :ddllob := :ddllob || chr (10) || chr (10) || '-- NO DDL for Grants found : ' || sqlerrm || chr (10);
   end;
end;
/

spool &&SPOOL_NAME

column ddllob format a350 word_wrapped

print ddllob

spool off

undefine ddllob

set heading on


-----------
-- OLD Version
-- column command format a300 WORD_WRAPPED
--
-- set pagesize 0
-- set long 90000
-- SELECT DBMS_METADATA.GET_DDL('PACKAGE_BODY','&&PACKAGE_NAME.',upper('&&OWNER.'))  as command FROM dual
-- /
--
-- set pagesize 0
-- set long 90000
-- SELECT DBMS_METADATA.GET_DDL('PACKAGE','&&PACKAGE_NAME.',upper('&&OWNER.'))  as command FROM dual
-- /

prompt ...
prompt check &&SPOOL_NAME for the sql
prompt ..
