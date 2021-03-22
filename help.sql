--==============================================================================
-- Author: Gunther Pippèrr
-- Desc:   SQL Script Overview
--==============================================================================

DOC 
-------------------------------------------------------------------------------
 
#The daily scripts for the DBA
===============================

	- dict.sql             - query the data dictionary - parameter 1 - part of the comments text

	- database.sql         - name and age of the database
	- status.sql           - status of the instance/cluster
	- cdb.sql              - check this DB (12c onwards) for plugable configuration
	- date.sql             - get the actual date and time of the DB
	- instance.sql         - status of the instance where the user is connected
	- limit.sql            - resource limits since last startup of the instances
	- dbfiles.sql          - list of all database data files
	
	- tablespace.sql             - Information about the tablespaces
	- tablespace_usage.sql       - Information usage on a tablespace - Parameter 1 the name of the tablespace
	- tablespace_ddl.sql         - get the DDL of a tablespace, show default storage options!  - Parameter name of the tablespace
	- tablespace_space.sql       - get a overview over the free and used space for a tablespace - parameter name of the tablespace
	- awr_tablespace_history.sql - get the historical Size of a tablespace from the AWR
	- tablespace_tab_storage.sql - show all tables on a tablespace
	- tablespace_autoextend.sql  - set all datafile of a tablespace to autoextend
	- tablespace_set_size.sql    - set all datafile of a tablespace to the same size
	- tablespace_create.sql      - print the ddl to create a uniform tablespace - Parameter Name of the tablespace
    - tablespace_last_objects.sql  - get the last 5 objects in a tablespace

	- sessions.sql             - actual connections to the database 
	- session_history.sql      - get a summary over the last active sessions 
	- session_long_active.sql  - all session that are longer active 
	- session_longops.sql      - get information about long running SQL statements
	- session_killed.sql       - get the process information for killed sessions
	- ses_statistic.sql        - get the statistic information of a session
	- my_opt_settings.sql      - Optimizer settings in my session
	- my_ses_stat.sql          - Satistic of my session
	- session_opt_settings.sql - Optimizer settings in a session - parameter 1 username
	- session_user_env.sql     - show all sys context values in a user session
	- session_user_nls_lang.sql - get the NLS Lang  User session setting (only SYS !)

	- starttrace.sql      - start a trace of my session
	- stoptrace.sql       - stop trace of my session
	- trace_status.sql    - show all traces in the database

	- service_session.sql - sessions per service over all instances 
	- trans.sql           - running transactions in the database
	- undo.sql            - show activity on the undo segment
	- undo_stat.sql       - show statistic for the undo tablespace usage
	- open_trans.sql      - all longer open running transactions in the database - uncommitted transaction!
	
	- bgprocess.sql       - Background processes in the database
	- process.sql         - actual processes in the database parameter 1 - name of the DB or OS User 
                                                             Parameter 2 - if Y shows also internal processes
	- process_get.sql      - show the information about the session with this PID - parameter 1 PID
	
	- resource_manager.sql - show the information about the resource manager  
	- resource_manager_sessions.sql - Show the resource manager settings of the running sessions
	- tempspace_usage.sql  - show processes using the temp tablespace
	- parallel.sql         - parallel SQL informations
	- parallel_dbms.sql    - DBMS_PARALLEL chunks in work
	
	- tns.sql              - show services and tns settings on services
	- tns_history.sql      - show services statistics for the last 12 hours (only services with some traffic)
	- taf.sql              - Check TAF settings of the connections
	- connection_pool.sql  - Show the Database Resident Connection Pooling (DRCP) Settings
	- ssl.sql              - check the  sql*net connection if ssl or encryption is in use
	- sqlnet.sql           - get SQL*Net Informations

	- locks.sql            - locks in the database - mode 6 is the blocker!
	- ddl_locks.sql        - check for DDL Locks

	- wait.sql             - waiting sessions
	- wait_text.sql        - text to a wait event - parameter 1 part of the event name
	- wait_get_name.sql    - search for a name of a wait event

	- latch.sql            - get Information’s about the DB latch usage
	- checkpoint.sql       - get the actual status for the instance recovery

	- my_user.sql          - who am I and over with service I connect to the database
	
	- nls.sql              - global and session NLS Settings
	- version.sql          - version of the database
	- test_sqlnet_fw.sql   - test the time-outs of SQL*Net

	- init.sql             - init.ora entries
	- init_rac.sql         - show init.ora parameter in a RAC Environment to check if same parameters on each node
	- db_events.sql        - test if some events are set in the DB environment
	- db_properties.sql    - get the database properties 

	- xmldb.sql            - show configuration of the XML DB
	- acl.sql              - show the acls of the Database (for security)
	- my_acl.sql           - show my rights
	
	- java.sql                    - java access rights
	- java_recomplie_invalid.sql  - compile invalid (resolve) java classes in a user schema 

	- invalid.sql          - show all invalid objects
	- invalid_synoyms.sql  - delete Script for invalid synonym
	- invalid_obj_report.sql  - get report for development for invalid objects in the database
	- invalid_constraints.sql - get all invalid constraints

	- user.sql             - rights and roles of a user and object grants - parameter 1 - Name of the user
	- users.sql            - overview over the DB users - parameter 1 - Name of the user 	
	- user_ddl.sql         - get the script to create a user - parameter 1 - Name of the user
	- user_history.sql     - get some static information for the login behavior of this user -  Parameter 1 - Name of the user
	- user_objects.sql     - show the counts of objects from none default users
	- user_oracle_default.sql  - define the list of the default oracle db schemas
	
	- vpd.sql              - show the VPD - Virtual Private Database Settings
	
	- user_tab.sql         - get all the tables and views of a user - parameter 1 - part of the table name
	- ls.sql               - gets all the tables and shows the size of the user tab
	
	- roles.sql            - all roles in the database - parameter 1 part of the role name
	- role.sql             - get the rights on a role
	- role_ddl.sql         - get the dll of one role in the database - parameter 1 the role name
	
	- any_rights.sql       - show all users with any rights in the database
	- inherit_rights.sql   - show all users with inherit priviliges rights

	- profile.sql          - profiles for the user of this database
	- proxy.sql            - proxy settings in the database
	- proxy_to.sql         - All schemas that can be switch to this schema with proxy rights - parameter 1 name of the schema
	- proxy_client.sql     - from which user you can connect to this user - parameter 1 the user

	- comment.sql          - search over all comments                    - parameter 1 - part of the comment text
	
	- desc.sql             - describe a table - parameter 1 Table name - 2 - part of the column name
	- tab.sql              - search a table or views in the database       - parameter 1 - part of the table
	- tab_overview_report.sql - report over all none default tables in the database
	- tab_cat.sql          - get the tables and views of the current user 
	- tab_count.sql        - count the entries in a table                 - parameter 1 - name of the table
	- tab_space.sql        - space usage of a table
	- tab_stat.sql         - get the statics of the table                 - parameter - Owner, Table name
	- tab_desc.sql         - describe the columns of the table            - parameter 1 - part of the table
	- tab_ddl.sql          - get the create script of a table             - parameter - Owner, Table name
	- tab_priv.sql         - get the priviliges on a tab                  - parameter - Owner, Table name
	- tab_last.sql         - get the change date of a record in the table - parameter - Owner, Table name
	- tab_mod.sql          - get the last modifications of the table      - parameter - Owner, Table name
	- tab_data_changes.sql - get an overview over changes on the tables of a user - parameter - Owner
	- tab_umlaut.sql       - check for tables/views if umlauts are used for the naming of tables and columns 
	- tab_identity_col.sql - get the sequence of a ID Column from the database  - parameter - Owner, Table name
	- my_tab_rights.sql    - get all rights on tables outside my schema
	
	- tab_usage.sql        - check if the table is used in the last time - parameter - Owner, Table name
	- tab_part.sql         - get the partition information of a table     - parameter - Owner, Table name
	- partition.sql        - Analyse the partitions of the tables of a user
	
	- tab_ext.sql          - get information about external tables  
	- tab_iot.sql          - show information about a index organized table - parameter - Owner, Table name
	- tab_iot_all.sql      - Show all IOT in the database
	
	- tab_mat.sql          - Information about materialized views
	- tab_mat_log.sql      - Information about materialized views Logs
	- refresh_group.sql    - Get all refresh groups of the DB for the materialized views
	- my_refresh_group.sql - Get all refresh groups of your Schema
	
	- tab_defekt_blocks.sql           - check for corrupted blocks
	- tab_defekt_blocks_bad_table.sql - create rowid table for all readable data for a table with a defect lob segment
	
	- tab_redef.sql             - example for an online table redefinition
	- tab_stat_overview.sql     - statistic over all table of a user parameter 1 - schema name
	- analyse_changed_rows.sql  - analyses changed row for a table
	- recreate_tables.sql       - create the script to reorganise the smaller tables of a tablespace with alter table move
	
	- column_type.sql - get all columns in the database with this data-type parameter 1 - data type - owner 
	- column.sql      - search all tables with this column name - parameter 1 - name of the column
	
	- synonym.sql        - search all synonym of a user - parameter - Owner, data type
	- synonym_detail.sql - get information over one synonym - parameter - Owner, synonym Name
	
	- lob.sql            - show the lob settings of the tables of the user - parameter - Owner
	- lob_detail.sql     -Get the details for the lob data type for this table - parameter owner and table name
	- dimension_ddl.sql - Get the DDL of a oracle dimension object in the database 
	
	- sequence.sql       - search a sequence in the database parameter 1 - name of the sequence
	
	- recycle.sql        - show the content summary of the dba recyclebin
	
	- tab_tablespace.sql        - get the tablespaces of the user    - parameter - Owner
	- tab_tablespace_all.sql    - get the used tablespace overview of this database 

	- index.sql       - get the information’s over a index            - parameter - Owner, Index name
	- index_all.sql   - get all indexes of a user                     - parameter - Owner
	- index_mon.sql   - check the result of index monitoring   
	- index_ddl.sql   - get the DDL of an index
	
	- obj_dep.sql         - get the dependencies of a object in the database - parameter - Owner, object name
	- obj_deps_report.sql - get a overview of dependencies in a database as HTML Report
	- obj_grants.sql      - get the grants for this object in the database    - parameter - Owner, object name
	- obj_last_ddl.sql    - get the last DDL for all objects of a user        - parameter - Owner

	- plsql_info.sql      - information about a pl/sql function/package
	- plsql_search.sql    - search for a pl/sql function/procedure also in packages - parameter Search String
	- plsql_depend.sql    - information about the dependencies of a package/procedure - parameter - Owner, object name
	- plsql_depend_on.sql - Which objects depends on this pl/sql code
	- plsql_errors.sql    - show the errors of pl/sql objects
	- plsql_dll.sql       - information about a pl/sql function/package       - parameter - Owner, object name
	- my_plsql.sql        - show all package of the current user
	- plsql_usage.sql     - which package are used in the last time and how often over the SGA Cache
	- plsql_running.sql   - actual running pl/sql in the database
	
	- select.sql      - select first 3 records of the table as list - parameter 1 - name of the table
	- view_count.sql  - count entries in a view                     - parameter 1 - name of the view
	- view_getsql.sql - get the real SQL statement behind the call of a view - parameter - Owner, view name
	
	- asm.sql         - asm disk status and filling degree of the asm disks
	
	- asm_disk.sql     - asm disk groups space
	- asm_all_disks.sql - show the disk infos
	- asm_balance.sql  - asm disk disk balance  - Parameter 1 - name of the disk group
	- asm_partner.sql  - Information about asm partner disk
	- asm_files.sql    - All files on an ASM disk group
	
	- asm_failgroup.sql - Show the failgroup information of a disk group - Parameter 1 - name of the disk group
	- asm_offline_failgroup.sql - create the script to offline all disks in a failgroup - Parameter 1 over the nameing convention of the disk!
	- asm_online_failgroup.sql  - create the script to online all failgroup with offline disks
	- asm_rebalance.sql - Show the rebalance information of a asm resync of disks
	- asm_attribute.sql - Show the parameter of a ASM Diskgroup - parameter 1 Diskgroup Name - parameter 2 - parameter name
	
	- flash.sql       - show the flash back information’s 
	- reco.sql        - recovery area settings and size
	- archive_log_status.sql - status of the archivelog files
	
	- redo.sql        - redo log information (use redo10g.sql for 10g/9i)
	- redo_change.sql - who create how much redo per day last 7 in the database
	- scn.sql         - scn in the archive log history 
	- sqn.sql         - sequence log
	
	- ext/tsc.sql       - table space size information
	- directory.sql     - show directories in the database
	- my_directory.sql  - show directories of the actual connect user  in the database
	- links.sql         - show the DB Links in the database
	- links_ddl.sql     - get the DDL of all DB links in the database
	- links_usage.sql   - get the sourcecode that use the DB links
	
	- audit.sql         - show the audit settings 
	- audit_sum.sql     - audit log summary
	- audit_login.sql   - audit the logins of users
	- audit_failed_login.sql - check for failed logins in the last time
	- audit_logoff_cleanup.sql - check for dropped Sessions in the last time
	
	- jobs.sql          - jobs in the database job$ and scheduler tasks info
	- jobs_dbms.sql     - jobs declared with dbms_job - old style jobs
	- jobs_sheduler.sql - jobs declared over the job scheduler
	- jobs_errors.sql   - jobs in the database job$ and scheduler tasks info with errors
	- jobs_window_resource_class.sql - show the relation between job windows , job classes and resource plans
	- jobs_logs.sql     - Details of a job
	
	- sga.sql          - show information about the oracle sga usage 
	- buffer.sql       - show information about the buffer cache usage / must run as sys
	- buffer_cache.sql - show information about objects in the buffer cache
	- pga.sql          - show information about the PGA usage
	
	- statistic.sql  - show information over the statistics on the DB  and stat age on tables and when the stats job runs
	- statistic_backup.sql - save all statistics of the DB in backup tables

	- cursor.sql     - show information about the cursor usage

	- sql_find.sql   - find a SQL Statement in the Cache - parameter 1 part of the SQL statement
	- sql_plan.sql   - get the Execution Plan for one SQL ID from the cache
	- sql_temp.sql   - SQL that use the temp table space for sorting
	- sql_show_bind.sql  - Show the bind variables of the SQL statement from the cursor Cache - parameter 1 - SQL ID
	- sql_parallel.sql   - Show the parallel execution for this statement - parameter 1 - SQL ID
	- sql_opt_settings.sql - Show the optimizer settings for this statement  - parameter 1 - SQL ID

	- sql_kill_session.sql  - create the command to kill all sessions running this SQL at the moment - parameter 1 - SQL ID
	- sql_purge_cursor.sql  -  purge the cursor out of the cache  - parameter 1 - SQL ID

	- sql_profile.sql          - show all profiles in the database
	- sql_profile_details.sql  - get the details of a SQL profile - parameter 1 - Profile Name
	- sql_baseline.sql         - get the defined baseline 
	- sql_baseline_evolve.sql  - evolve  and get the details of one  baseline - parameter 1 - the baseline sql_handle name
	- sql_baseline_plan.sql    - get the details of of a plan in a baseline - parameter 1 - the baseline sql_baseline_plan
    - sql_session_stat.sql         - get statistics from running session for this SQL - parameter 1 - SQL ID
	
	- get_plan.sql  - get the plan of the last "explain plan for"

	- ash.sql                 - usage of the active session history ASH
	
	- awr.sql                 - usage of the AWR repository and of the SYSAUX table space 
	- awr_sql_find.sql        - find a SQL Statement in the AWR History - parameter 1 part of the SQL statement
	- awr_sql_find_report.sql - create overview report over the usage of a SQL statement or hint - parameter 1 part of the SQL statement
	- awr_sql_stat.sql        - get statistic of the SQL execution of one statement - parameter 1 - SQL ID
	- awr_sql_hash.sql        - get the different hashes if exits                   - parameter 1 - SQL ID
	- awr_sql_plan.sql        - get plan of the SQL execution of one statement - parameter 1 - SQL ID
	- awr_sql_time_stat.sql   - get all SQL statements from the awr for this time - parameter 1 - Start date  - parameter 2 end date in DE format
	- awr_temp_usage.sql      - get the SQL that use temp tablespace from the awr for this time - parameter 1 - Start date  - parameter 2 end date in DE format
	- awr_pga_stat.sql        - statistic of the pga usage
	- awr_sys_stat.sql        - statistic of system historical statistics information

	- awr_session_stat.sql    - statistic of the sessions of a user
	- awr_session_resource_plan_historie.sql - Show the consumer group of all history active sessions of a user
	- awr_act_active_sessions.sql            - get information about the act active Session in the last 90 minutes
	- awr_ash_top_sql.sql			 - select the last top sql statements from the active session history
	- awr_act_blocking_sessions.sql          - get information about blocking sessions in the database
	- awr_session_none_technical_user.sql    - get information about none technical user sessions
	- awr_changed_plans.sql                  - search for changed plans in a time period - parameter 1 - Start date  - parameter 2 end date in DE format
	- awr_resourcelimit.sql			 - display the resource limits of the last days
	- awr_os_stat.sql                        - display the OS statistic of the last days  
	- awr_call_awr_report.sql                - create AWR Report of the database
	- awr_call_ash_report.sql                - create ASH Report of the database
	- awr_call_sqlmonitor_report.sql         - call a sql Monitor Report

	- statspack_delete_job.sql               - create a job to clean the statspack repository
	
	- calibrate_io.sql     - Use I/O calibrate to analyses io of the database and set the internal I/O views
	- system_stat.sql      - get the DB internal system stat values like workload statistic and I/O calibrate values
	
	- ctx.sql              - Oracle Text indexes for a user and ctx settings - parameter 1 - name of the user
	
	- rman.sql                - rman settings of this database and summary information about the last backups for this database and the block change tracking feature
	- rman_process.sql        - get information over running rman processes for tracing
	- rman_status.sql         - get the status of the last backup in the database
	
	- datapump.sql            - show datapump sessions
	- datapump_filter.sql     - show all possible filter values für the INCLUDE/EXCLUDE parameter of datapump
	
	- standby_status.sql      - status of a standby / DG environment
	
	- streams_status.sql      - status of streams replication
	- streams_config.sql      - streams configuration
	- streams_logs.sql        - show the streams archive logs - which can be deleted 
	- streams_print_error.sql - print the SQL Statements for all LCRS in a transaction if a streams error occurs
	- streams_print_lcr.sql   - print the LCR of one Message
	- streams_logmnr.sql      - information about the log miner process
	
	- db_alerts.sql           - get the internal metric settings of the DB side monitoring 
	- db_alerts_set.sql       - set the threshold of a metric
	
	- health_mon.sql          - call the health monitoring in 11g - get the parameter 
	
	- login.sql               - set the login prompt
	
	- http_ftp_port.sql       - get the port settings of the database
	
	- ords.sql                - get the ORDS REST service definitions
	- apex_version.sql        - get the ORDS and APEX Version in this DB
	
	#Create Scripts
	=================
	
	- clean_user.sql            - create the DDL to delete every object in the schema - parameter 1 - user name
	
	- space_tablespace.sql      - create the DDL to shrink a table space - parameter 1 - Name of the table space (%) for all
	- space_tablespace_auto.sql - shrink each possible tablespace without asking 				
	
	- recreate_index.sql        - Script to create a index recreation script 
	- recreate_table.sql        - Script to reorganize all small tables in a tablespace, off-line with !alter Table move!
	
	
	- create_mon_index.sql      - Script to create index enable or disable monitoring scripts for a user - parameter 1 - user name
	
	- create_all_statistic.sql  - Recreate the statistic of the database
	
	#Reports
	=================
	
	- check_col_usage.sql - HTML Report - Table column used in SQL Statements but not indexed and all indexes with more than one column to check for duplicate indexing

	- top_sql.sql         - HTML Report - Top SQL Statements in the database for Buffer / CPU / Sort Usage
	- sql_user_report.sql - HTML Report - Show all SQL statements for this user in the SGA 

	- audit_rep.sql       - HTML Report - Audit Log entries

	- licence.sql         - HTML Report - License Report Overview - Feature Usage

	#Setup
	=================

	- 01-db-setup/create_global_errorlog.sql     - create a global error table and error trigger + maintain job
	- 01-db-setup/delete_global_errorlog.sql     - delete the global error trigger + error table
	- 01-db-setup/report_global_errorlog.sql	 - template to create HTML report over all errors in the sql error log
	
	- 01-db-setup/create_audit_log_database.sql  - create own table space for auditlog, move audit log to this table pace - create clean job
	- 01-db-setup/set_audit_minimal_settings.sql - set minimal audit parameter
	
	- 01-db-setup/monitor_user_sessions.sql      - create a log table to monitor user connection over some time
	- 01-db-setup/ create-logon-trigger-user-handling.sql - create logon trigger to restrict access to the database
	
	#The OEM Query Scripts
	=================
	- get the the help of the OEM scripts use oem/help_oem.sql

-------------------------------------------------------------------------------
#

