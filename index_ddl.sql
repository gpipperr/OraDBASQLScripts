--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   extract the DDL of index  in the database
--
-- Parameter 2: Owner of the table/object
-- Parameter 1: Name of the index
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define OWNER    = '&1'
define INDEX_NAME = '&2'

prompt
prompt Parameter 1 = Owner Name   => &&OWNER.
prompt Parameter 2 = Index Name   => &&INDEX_NAME.
prompt

variable ddllob clob

set heading off
set echo off

set long 1000000;

declare
   cursor c_tab_idx
   is
      select index_name, owner
        from dba_indexes
       where     index_name = upper ('&&INDEX_NAME.')
             and TABLE_OWNER = upper ('&&OWNER.');
begin
-- set the transformation attributes
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY',             true );
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR',      true );
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',    false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'OID',                false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE',         true );
-- no Schema Name inside
	DBMS_METADATA.SET_TRANSFORM_PARAM(dbms_metadata.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);

   --
   :ddllob := '-- call Index DLL for Index &&OWNER..&&INDEX_NAME.';
   dbms_output.put_line (:ddllob);

   -- get the index DDL for this table
   for rec in c_tab_idx
   loop
      :ddllob := :ddllob || chr (10) || chr (10) || '-- DDL for Index : ' || rec.index_name || chr (10);
      :ddllob := :ddllob || dbms_metadata.get_ddl ('INDEX', rec.index_name, rec.owner);
   end loop;
end;
/

print ddllob

undefine ddllob

set heading on