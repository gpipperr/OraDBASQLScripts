--==============================================================================
-- GPI - Gunther Pippèrr
-- Example for a table redefinition script
--==============================================================================
-- http://www.dba-oracle.com/t_online_table_reorganization.htm
-- http://www.dba-oracle.com/t_dbms_redefinition_example.htm
-- http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_redefi.htm#ARPLS67521
-- http://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/dbms_redefinition/index.html
--==============================================================================

---------------------------------------
set verify off
set linesize 130 pagesize 300 
set echo on
set timing on
set time on
set serveroutput on

---------------------------------------
-- Parameter
--define USER_NAME   ='GPI'
--define TABLE_NAME  ='TAB_TEST'
--define ORDER_BY_COL='ID'
--define TABLE_SPACE ='tablespace DATA'
--define SET_PARALLEL=8

define USER_NAME   ='&1'
define TABLE_NAME  ='&2'
define ORDER_BY_COL='&3'
define TABLE_SPACE ='&4'
define SET_PARALLEL=&5

spool log_file_&&USER_NAME._&&TABLE_NAME._rebuild.log

---------------------------------------
-- set flashback restore point
-- CREATE RESTORE POINT before_redefinition;


---------------------------------------
whenever sqlerror exit 2;

---------------------------------------
-- Verify if Table can be redefined

begin
   dbms_redefinition.can_redef_table (uname       => '&&USER_NAME'
                                    ,  tname       => '&&TABLE_NAME'
                                    ,  options_flag => dbms_redefinition.cons_use_pk
                                    ,  part_name   => null);
end;
/

---------------------------------------
-- create interim table
-- adjust individually
-- !!! Attention default values like sysdate are not copied by a create table as select!
-- see : Create Table As Select Does Not Copy Table's Default Values. (Doc ID 579636.1)

create table &&USER_NAME..&&TABLE_NAME._STAGE &&TABLE_SPACE COMPRESS FOR ALL OPERATIONS as select * from &&USER_NAME..&&TABLE_NAME. where 1=2;

---------------------------------------
-- remove not null constraints to avoid this error
-- ORA-01442: column to be modified to NOT NULL is already NOT NULL
-- ORA-06512: at "SYS.DBMS_REDEFINITION", line 984
-- ORA-06512: at "SYS.DBMS_REDEFINITION", line 1726

begin
   for i in (select owner
                  ,  table_name
                  ,  constraint_name
                  ,  search_condition
               from dba_constraints
              where     owner = '&&USER_NAME.'
                    and table_name = '&&TABLE_NAME._STAGE'
                    and constraint_type = 'C')
   loop
      if i.search_condition like '%IS NOT NULL%'
      then
         dbms_output.put_line (
            'INFO -- remove constraint ::' || i.owner || '.' || i.table_name || ' drop constraint ' || i.constraint_name);

         execute immediate 'alter table ' || i.owner || '.' || i.table_name || ' drop constraint ' || i.constraint_name;
      end if;
   end loop;
end;
/

---------------------------------------
-- enable parallel in this session
alter session force parallel dml parallel   &&SET_PARALLEL.;
alter session force parallel query parallel &&SET_PARALLEL.;

----------------------------------------
-- store original commmets due bug
-- Bug 12765293 - ORA-600 [kkzuord_copycolcomcb.2.prepare] may be seen during DBMS_REDEFINITION (Doc ID 12765293.8)
--
-- remember comments

create table &&USER_NAME..&&TABLE_NAME._t_c
as
   select *
     from dba_tab_comments
    where     owner = '&&USER_NAME.'
          and table_name = '&&TABLE_NAME';

create table &&USER_NAME..&&TABLE_NAME._c_c
as
   select *
     from dba_col_comments
    where     owner = '&&USER_NAME.'
          and table_name = '&&TABLE_NAME';

-- cut comments
comment on table &&USER_NAME..&&TABLE_NAME. is '';
------------------------------------
-- for all columns

declare
   cursor c_comment
   is
      select column_name, table_name, owner
        from dba_col_comments
       where     owner = '&&USER_NAME.'
             and table_name = '&&TABLE_NAME';
begin
   for rec in c_comment
   loop
      dbms_output.put_line (
         'INFO -- set COMMENT ON column ' || rec.owner || '.' || rec.table_name || '.' || rec.column_name || ' is ''-''');

      execute immediate 'COMMENT ON column ' || rec.owner || '.' || rec.table_name || '.' || rec.column_name || ' is ''-''';
   end loop;
end;
/


--------------------------------------
--
-- check if comments removed

column column_name format a20
column comments    format a50

select column_name, comments
  from dba_col_comments
 where     owner = '&&USER_NAME.'
       and table_name = '&&TABLE_NAME'
/

select comments
  from dba_tab_comments
 where     owner = '&&USER_NAME.'
       and table_name = '&&TABLE_NAME'
/


---------------------------------------
-- Start the redefinition process

begin
   dbms_redefinition.START_REDEF_TABLE (uname       => '&&USER_NAME'
                                      ,  orig_table  => '&&TABLE_NAME'
                                      ,  int_table   => '&&TABLE_NAME._STAGE'
                                      ,  col_mapping => null
                                      ,  options_flag => dbms_redefinition.cons_use_pk
                                      ,  orderby_cols => '&&ORDER_BY_COL'
                                      ,  part_name   => null);
end;
/

-----------------------------------
-- to stop the process use this function
--
--begin
--  DBMS_REDEFINITION.ABORT_REDEF_TABLE (
--          uname            => '&&USER_NAME'
--           , orig_table   => '&&TABLE_NAME'
--           , int_table    => '&&TABLE_NAME._STAGE'
--       , part_name    => null);
-- end;
--/



------ Constraints -----------
-- fix constraint names
--

-- declare
--     cursor c_constraints
--       is
--           select orig_tab.constraint_name  orig_constraint_name
--                 ,  stage_tab.constraint_name int_constraint_name
--             from (select * from dba_cons_columns where table_name = '&&TABLE_NAME'  and owner='&&USER_NAME') orig_tab
--                 , (select * from dba_cons_columns where table_name = '&&TABLE_NAME._STAGE' and owner='&&USER_NAME') stage_tab
--             where orig_tab.column_name = stage_tab.column_name;
-- begin
--     for rec in c_constraints
--     loop
--         dbms_output.put_line('INFO -- register constraints on &&USER_NAME..&&TABLE_NAME. '||rec.orig_constraint_name);
--         DBMS_REDEFINITION.REGISTER_DEPENDENT_OBJECT(
--                     uname             => '&&USER_NAME'
--                 ,    orig_table        => '&&TABLE_NAME'
--                 ,    int_table         => '&&TABLE_NAME._STAGE'
--                 ,     dep_type          => DBMS_REDEFINITION.CONS_CONSTRAINT
--                 ,     dep_owner         => '&&USER_NAME'
--                 ,    dep_orig_name     => rec.orig_constraint_name
--                 ,     dep_int_name      => rec.int_constraint_name
--         );
--     end loop;
-- end;
-- /

---------------------------------------
-- Copy dependent objects
-- constraints copied enabled missing constraints!
--

declare
   v_error_count   pls_integer;
begin
   dbms_redefinition.COPY_TABLE_DEPENDENTS (uname       => '&&USER_NAME'
                                          ,  orig_table  => '&&TABLE_NAME'
                                          ,  int_table   => '&&TABLE_NAME._STAGE'
                                          -- copy the indexes using the physical parameters of the source indexes
                                          ,  copy_indexes => dbms_redefinition.cons_orig_params
                                          ,  copy_triggers => true
                                          ,  copy_constraints => true
                                          ,  copy_privileges => true
                                          ,  ignore_errors => false
                                          ,  num_errors  => v_error_count
                                          ,  copy_statistics => false
                                          ,  copy_mvlog  => false);

   if v_error_count > 0
   then
      raise_application_error (-20100, 'Found ' || v_error_count || ' Errors cloning dependencies');
   end if;
end;
/

---------------------------------------
-- Check for any errors
set long 34000
column object_name   format a32
column base_table_name   format a32 fold_after
column ddl_txt format a100

select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS
/

---------------------------------------
-- Synchronize the interim table (optional)

begin
   dbms_redefinition.SYNC_INTERIM_TABLE (uname       => '&&USER_NAME'
                                       ,  orig_table  => '&&TABLE_NAME'
                                       ,  int_table   => '&&TABLE_NAME._STAGE'
                                       ,  part_name   => null);
end;
/


---------------------------------------
-- check if all data is synced
---

select count (*) entries, '&&TABLE_NAME.' from &&USER_NAME..&&TABLE_NAME.
union all
select count (*) entries, '&&TABLE_NAME._STAGE' from &&USER_NAME..&&TABLE_NAME._stage
/


---------------------------------------
-- Complete the redefinition
-- and switch table

begin
   dbms_redefinition.SYNC_INTERIM_TABLE (uname       => '&&USER_NAME'
                                       ,  orig_table  => '&&TABLE_NAME'
                                       ,  int_table   => '&&TABLE_NAME._STAGE'
                                       ,  part_name   => null);

   dbms_redefinition.FINISH_REDEF_TABLE (uname       => '&&USER_NAME'
                                       ,  orig_table  => '&&TABLE_NAME'
                                       ,  int_table   => '&&TABLE_NAME._STAGE'
                                       ,  part_name   => null);
end;
/


----------------------------------------
-- fix not null constraints
-- fix wrong fk constraints
-- see support node 1089860.1
--
--
alter session set ddl_lock_timeout=10;
--
----------------------------------------

declare
   cursor c_enable_const
   is
      select constraint_name, validated
        from dba_constraints
       where     table_name = '&&TABLE_NAME'
             and owner = '&&USER_NAME'
             and validated != 'VALIDATED';

   cursor c_fk_constraint
   is
      select 'alter table ' || sc.owner || '.' || sc.table_name || ' drop constraint ' || sc.constraint_name || ';' as command
        from dba_constraints sc, dba_constraints tc
       where     sc.r_constraint_name = tc.constraint_name
             and sc.owner = '&&USER_NAME'
             and tc.table_name like '%STAGE';

   cursor c_stage_constraint
   is
        select 'alter table ' || sc.owner || '.' || sc.table_name || ' drop constraint ' || sc.constraint_name || ';' as command
          from dba_constraints sc
         where     sc.owner = '&&USER_NAME'
               and sc.table_name like '%STAGE'
      order by sc.table_name;
begin
   -- re enable
   for rec in c_enable_const
   loop
      -- !!!!!!!!!!!! -- check                ---------------!!!!!
      -- use NOVALIDATE to spare some time to enable the constraint
      dbms_output.put_line ('Info -- call ALTER TABLE &&TABLE_NAME ENABLE NOVALIDATE CONSTRAINT ' || rec.constraint_name);

      begin
         execute immediate 'ALTER TABLE &&USER_NAME..&&TABLE_NAME ENABLE NOVALIDATE CONSTRAINT ' || rec.constraint_name;
      exception
         when others
         then
            dbms_output.put_line (
               'Error -- enable constraint ' || rec.constraint_name || ' failed! SQLERRM:' || sqlcode || ' - ' || sqlerrm);
      end;
   end loop;

   -- constraint on the FK tables
   for rec in c_fk_constraint
   loop
      dbms_output.put_line ('Info -- disabe FK -- call ' || rec.command);

      begin
         execute immediate '' || rec.command;
      exception
         when others
         then
            dbms_output.put_line (
               'Error -- enable constraint ' || rec.command || ' failed! SQLERRM:' || sqlcode || ' - ' || sqlerrm);
      end;
   end loop;

   -- constraint on the stage tables
   for rec in c_stage_constraint
   loop
      dbms_output.put_line ('Info -- disable Constraint -- call ' || rec.command);

      begin
         execute immediate '' || rec.command;
      exception
         when others
         then
            dbms_output.put_line (
               'Error -- enable constraint ' || rec.command || ' failed! SQLERRM:' || sqlcode || ' - ' || sqlerrm);
      end;
   end loop;
end;
/

----------------------------------------


----------------------------------------
-- check that all constraints in the db are enabled
--

column owner                format a20
column table_name            format a30
column constraint_name     format a30
column validated             format a20

select owner
     ,  table_name
     ,  constraint_name
     ,  validated
  from dba_constraints
 where     owner = '&&USER_NAME'
       and validated != 'VALIDATED'
/



----------------------------------------
-- recreate statistic on the table
--

begin
   dbms_stats.gather_table_stats (ownname     => '&&USER_NAME.'
                                ,  tabname     => '&&TABLE_NAME.'
                                ,  estimate_percent => dbms_stats.auto_sample_size
                                ,  method_opt  => 'FOR ALL COLUMNS SIZE auto'
                                ,  cascade     => true
                                ,  degree      => &&SET_PARALLEL.);
end;
/

----------------------------------------
-- restore original comments due bug
-- Bug 12765293 - ORA-600 [kkzuord_copycolcomcb.2.prepare] may be seen during DBMS_REDEFINITION (Doc ID 12765293.8)
--

declare
   cursor c_c_comment
   is
      select column_name
           ,  table_name
           ,  owner
           ,  comments
        from &&USER_NAME..&&TABLE_NAME._c_c
       where     owner = '&&USER_NAME.'
             and table_name = '&&TABLE_NAME';

   cursor c_t_comment
   is
      select table_name, owner, comments
        from &&USER_NAME..&&TABLE_NAME._t_c
       where     owner = '&&USER_NAME.'
             and table_name = '&&TABLE_NAME';
begin
   for rec in c_c_comment
   loop
      dbms_output.put_line (
            'INFO -- set COMMENT ON column '
         || rec.owner
         || '.'
         || rec.table_name
         || '.'
         || rec.column_name
         || ' is '''
         || rec.comments
         || '''');

      execute immediate
            'COMMENT ON column '
         || rec.owner
         || '.'
         || rec.table_name
         || '.'
         || rec.column_name
         || ' is '''
         || replace (rec.comments, '''', '''''')
         || '''';
   end loop;

   for rec in c_t_comment
   loop
      dbms_output.put_line (
         'INFO -- set COMMENT ON TABLE ' || rec.owner || '.' || rec.table_name || ' is ''' || rec.comments || '''');

      execute immediate
         'COMMENT ON TABLE ' || rec.owner || '.' || rec.table_name || ' is ''' || replace (rec.comments, '''', '''''') || '''';
   end loop;
end;
/

--------------------------------------
--
-- check if comments exits

column column_name format a20
column comments    format a50

select column_name, comments
  from dba_col_comments
 where     owner = '&&USER_NAME.'
       and table_name = '&&TABLE_NAME'
/

select comments
  from dba_tab_comments
 where     owner = '&&USER_NAME.'
       and table_name = '&&TABLE_NAME'
/

-- remove the interim table
drop table &&USER_NAME..&&TABLE_NAME._t_c;
drop table &&USER_NAME..&&TABLE_NAME._c_c;


----------------------------------------
-- check index names
-- rename if necessary
-- example TMP$$_ will be added by redef
--

declare
   cursor c_index
   is
      select index_name, owner
        from dba_indexes
       where     owner = '&&USER_NAME.'
             and table_name = '&&TABLE_NAME.'
             and index_name like 'TMP$$_%';
begin
   for rec in c_index
   loop
      dbms_output.put_line ('INFO -- rename index');

      execute immediate
         'alter index ' || rec.owner || '.' || rec.index_name || ' rename to ' || replace (rec.index_name, 'TMP$$_', '');
   end loop;
end;
/


---------------------------
-- check the tablespace of the switched table
column table_name         format a32
column tablespace_name    format a20
column COMPRESSION        format a8
column COMPRESS_FOR        format a8

select table_name
     ,  tablespace_name
     ,  COMPRESSION
     ,  COMPRESS_FOR
  from dba_tables
 where     owner = '&&USER_NAME.'
       and table_name in ('&&TABLE_NAME.', '&&TABLE_NAME._STAGE')
/

---------------------------
-- check for invalid
--
@invalid

---------------------------------------
-- check if all data is synced
---

select count (*) entries, '&&TABLE_NAME.' from &&USER_NAME..&&TABLE_NAME.
union all
select count (*) entries, '&&TABLE_NAME._STAGE' from &&USER_NAME..&&TABLE_NAME._stage
/

-------------------------------------
---
--- check for constraints

select sc.constraint_name as child_constraint
     ,  sc.constraint_type as child_type
     ,  sc.table_name as child_tab
     ,  sc.validated as child_validated
     ,  sc.status as child_status
     ,  tc.constraint_name as fk_constraint
     ,  tc.constraint_type as fk_type
     ,  tc.table_name as fk_table_name
     ,  tc.validated as fk_validated
     ,  tc.status as fk_status
  from dba_constraints sc, dba_constraints tc
 where     sc.r_constraint_name = tc.constraint_name
       and sc.owner = '&&USER_NAME.'
       and tc.table_name = '&&TABLE_NAME._STAGE'
/

prompt .... not constraint should point to this tables!



---------------------------------------
-- if table is switched to
-- Drop the interim table
--drop table &&USER_NAME..&&TABLE_NAME._STAGE purge
--/

---------------------------------------
-- set flashback restore point
-- drop RESTORE POINT before_redefinition;
---------------------------------------



spool off