-- ==============================================================
-- GPI - Gunther Pippèrr
-- create the script to reorganise the smaller tables of a tablespace with alter table move
-- Work in progress
-- ==============================================================
-- for more Examples see: 
-- http://www.doag.org/home/aktuelle-news/article/defragmentierung-von-tablespaces-fuer-arme.html
-- http://www.pythian.com/blog/oracle-file-extent-map-the-old-fashioned-way/
-- ==============================================================
set verify  off
set linesize 130 pagesize 4000 

define TABLESPACE_NAME = '&1'

prompt
prompt Parameter 1 = Tablespace Name => &&TABLESPACE_NAME.
prompt

-------------------
-- create spool name
col SPOOL_NAME_COL new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_table_rebuild_&&TABLESPACE_NAME..sql'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/


spool &&SPOOL_NAME

prompt
prompt spool recreate_&&SPOOL_NAME.log
prompt
prompt
prompt prompt  ============ Start ================
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as start_date from dual
prompt /
prompt prompt  ===================================
prompt
prompt
prompt set heading  on
prompt set feedback on
prompt set echo on
prompt

---------------------------------------------------------------------------------------------------------
prompt Enable Row movement for all tables
-- Alter Table <tablename> enable rowmovement;

select 'alter table ' || owner || '.' || table_name || ' enable rowmovement;'
  from dba_tables
 where tablespace_name = upper ('&&TABLESPACE_NAME.');

prompt Shrink all not partitioned tables
-- Alter Table <tablename> shrink space cascade;

select 'alter table ' || owner || '.' || table_name || ' shrink space cascade;'
  from dba_tables
 where     tablespace_name = upper ('&&TABLESPACE_NAME.')
       and PARTITIONED = 'NO';

---------------------------------------------------------------------------------------------------------
prompt Shrink all partitioned tables (for each Partition)
-- Alter Table <tablename> modify partition <partitionname> shrink space

select 'alter table ' || owner || '.' || table_name || ' modify partition ' || p.PARTITION_NAME || ' shrink space;'
  from dba_tables t, dba_tab_partitions p
 where     t.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.PARTITIONED = 'YES'
       and p.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and p.SUBPARTITION_COUNT = 0
       and t.owner = p.table_owner
       and t.table_name = p.table_name;

--------------------------------------------------------------------------------------------------------
prompt Partionierte Tabelle (mit Subpartitionen) (für jede Subpartition)
--Alter Table <tablename> modify subpartition <subpartitionname> shrink space

select 'alter table ' || owner || '.' || table_name || ' modify subpartition ' || p.PARTITION_NAME || ' shrink space;'
  from dba_tables t, dba_tab_subpartitions p
 where     t.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.PARTITIONED = 'YES'
       and p.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.owner = p.table_owner
       and t.table_name = p.table_name;



---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- move free segments to gether
--
alter tablespace &&TABLESPACE_NAME. coalesce;
--


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--
--  Start to move all the data
--
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- prompt Move all tables > 10MB


--Nicht partionierte Tabelle
prompt move all not partitioned tables
-- Alter Table <tablename> move;

select 'alter table ' || owner || '.' || table_name || ' move;'
  from dba_tables
 where     tablespace_name = upper ('&&TABLESPACE_NAME.')
       and PARTITIONED = 'NO';

--Partionierte Tabelle
--Alter Table <tablename> move partition …;

select 'alter table ' || owner || '.' || table_name || ' move partition ' || p.PARTITION_NAME || ';'
  from dba_tables t, dba_tab_partitions p
 where     t.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.PARTITIONED = 'YES'
       and p.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and p.SUBPARTITION_COUNT = 0
       and t.owner = p.table_owner
       and t.table_name = p.table_name;

--Partionierte Tabelle (mit Subpartitionen)
--Alter Table <tablename> move subpartition;

select 'alter table ' || owner || '.' || table_name || ' move subpartition ' || p.PARTITION_NAME || ';'
  from dba_tables t, dba_tab_subpartitions p
 where     t.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.PARTITIONED = 'YES'
       and p.tablespace_name = upper ('&&TABLESPACE_NAME.')
       and t.owner = p.table_owner
       and t.table_name = p.table_name;

--LOB nicht partionierte Tabelle
--Alter Table <tablename> move LOB (<columnname>) store as <segmentname>;

--LOB partionierte Tabelle
--Alter Table <tablename> move partition <partitionname>LOB (<columnname>) store as <segmentname>;

--LOB partionierte Tabelle (mit Subpartitionen)
--Alter Table <tablename> move subpartition <subpartitionname> LOB (<columnname>) store as <segmentname>;

--Nicht partionierter Index
--alter index <indexname> rebuild;

--Partionierter Index
--Alter index <indexname> rebuild partition <partitionname>;

-- Partionierter Index (mit Subpartitionen)
-- Alter index <indexname> rebuild subpartition <subpartitionname>;

--IOT
-- Alter Table <IOtablename> move;


spool off


	
