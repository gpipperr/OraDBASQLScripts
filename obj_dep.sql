--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the dependencies of a object in the database - parameter - Owner, object name
-- Date:   08.2013
--==============================================================================
-- http://www.dba-oracle.com/t_tracking_table_constraint_dependencies.htm
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = Tab Name   => &&TAB_NAME.
prompt

ttitle left  "Dependency Usage of the table &OWNER..&TAB_NAME." skip 2

column clevel    heading "Object|level"         format a16
column obj_name  heading "Object|name"          format a40
column type      heading "Object|type"          format a8
column referenced_type like type
column ref_obj   heading "Ref|object"           format a40

select  lpad(' ', 2 * (level - 1)) || to_char(level, '999') as clevel
      , type
      , owner || '.' || name as obj_name
      , referenced_owner || '.' || referenced_name  as ref_obj
	  , referenced_type
  from all_dependencies
 start with owner = upper('&OWNER')
        and name = upper('&TAB_NAME')
connect by prior referenced_owner = owner
       and prior referenced_name = name
       and prior referenced_type = type
/	   

prompt
prompt ... alternativ use the utldtree utility $ORACLE_HOME/rdbms/admin/utldtree.sql 
prompt ... to create the helper function and call =>  deptree_fill('object_type', 'object_owner', 'object_name'); |  select * from ideptree;
prompt
