--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: HTML Report - License Report Overview - Feature Usage
--==============================================================================
set verify off
set linesize 130 pagesize 300 

col SPOOL_NAME_COL new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_licence.html'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/



spool &&SPOOL_NAME

set markup html on

ttitle center "Database Information" skip 2

  select v.instance_name
       ,  v.inst_id
       ,  v.host_name
       ,  to_char (d.dbid) as dbid
       ,  d.name
       ,  to_char (d.created, 'dd.mm.yyyy hh24:mi') as "Create Time"
       ,  (select banner
             from v$version
            where banner like 'Oracle Data%')
             as edition
    from gv$database d, gv$instance v
order by v.instance_name
/


ttitle center "Installed Options" skip 2

  select parameter as "Option", value as "Installed"
    from v$option
   where value = 'TRUE'
order by value desc
/

ttitle center "Last Feature Check" skip 2

  select to_char (FS.LAST_SAMPLE_DATE, 'dd.mm.yyyy hh24:mi') as "Last Feature Check"
    from dba_feature_usage_statistics fs
group by FS.LAST_SAMPLE_DATE
/

ttitle center "11g Feature Overview" skip 2

prompt "for the 'Oracle Supported Script see  Options / Features View 11g see metalink note Database Options/Management Packs Usage Reporting for Oracle Database 11g Release 2 [ID 1317265.1]"

with v_feature
     as (select a feature_option, b detailname
           from (select 'Active Data Guard' a, 'Active Data Guard - Real-Time Query on Physical Standby' b from dual
                 union all
                 select 'Advanced Compression', 'HeapCompression' from dual
                 union all
                 select 'Advanced Compression', 'Backup BZIP2 Compression' from dual
                 union all
                 select 'Advanced Compression', 'Backup DEFAULT Compression' from dual
                 union all
                 select 'Advanced Compression', 'Backup HIGH Compression' from dual
                 union all
                 select 'Advanced Compression', 'Backup LOW Compression' from dual
                 union all
                 select 'Advanced Compression', 'Backup MEDIUM Compression' from dual
                 union all
                 select 'Advanced Compression', 'Backup ZLIB, Compression' from dual
                 union all
                 select 'Advanced Compression', 'SecureFile Compression (user)' from dual
                 union all
                 select 'Advanced Compression', 'SecureFile Deduplication (user)' from dual
                 union all
                 select 'Advanced Compression', 'Data Guard' from dual
                 union all
                 select 'Advanced Compression', 'Oracle Utility Datapump (Export)' from dual
                 union all
                 select 'Advanced Compression', 'Oracle Utility Datapump (Import)' from dual
                 union all
                 select 'Advanced Security', 'ASO native encryption and checksumming' from dual
                 union all
                 select 'Advanced Security', 'Transparent Data Encryption' from dual
                 union all
                 select 'Advanced Security', 'Encrypted Tablespaces' from dual
                 union all
                 select 'Advanced Security', 'Backup Encryption' from dual
                 union all
                 select 'Advanced Security', 'SecureFile Encryption (user)' from dual
                 union all
                 select 'Change Management Pack (GC)', 'Change Management Pack (GC)' from dual
                 union all
                 select 'Data Masking Pack', 'Data Masking Pack (GC)' from dual
                 union all
                 select 'Data Mining', 'Data Mining' from dual
                 union all
                 select 'Diagnostic Pack', 'Diagnostic Pack' from dual
                 union all
                 select 'Diagnostic Pack', 'ADDM' from dual
                 union all
                 select 'Diagnostic Pack', 'AWR Baseline' from dual
                 union all
                 select 'Diagnostic Pack', 'AWR Baseline Template' from dual
                 union all
                 select 'Diagnostic Pack', 'AWR Report' from dual
                 union all
                 select 'Diagnostic Pack', 'Baseline Adaptive Thresholds' from dual
                 union all
                 select 'Diagnostic Pack', 'Baseline Static Computations' from dual
                 union all
                 select 'Tuning Pack', 'Tuning Pack' from dual
                 union all
                 select 'Tuning Pack', 'Real-Time SQL Monitoring' from dual
                 union all
                 select 'Tuning Pack', 'SQL Tuning Advisor' from dual
                 union all
                 select 'Tuning Pack', 'SQL Access Advisor' from dual
                 union all
                 select 'Tuning Pack', 'SQL Profile' from dual
                 union all
                 select 'Tuning Pack', 'Automatic SQL Tuning Advisor' from dual
                 union all
                 select 'Database Vault', 'Oracle Database Vault' from dual
                 union all
                 select 'WebLogic Server Management Pack Enterprise Edition', 'EM AS Provisioning and Patch Automation (GC)'
                   from dual
                 union all
                 select 'Configuration Management Pack for Oracle Database', 'EM Config Management Pack (GC)' from dual
                 union all
                 select 'Provisioning and Patch Automation Pack for Database'
                      ,  'EM Database Provisioning and Patch Automation (GC)'
                   from dual
                 union all
                 select 'Provisioning and Patch Automation Pack', 'EM Standalone Provisioning and Patch Automation Pack (GC)'
                   from dual
                 union all
                 select 'Exadata', 'Exadata' from dual
                 union all
                 select 'Label Security', 'Label Security' from dual
                 union all
                 select 'OLAP', 'OLAP - Analytic Workspaces' from dual
                 union all
                 select 'Partitioning', 'Partitioning (user)' from dual
                 union all
                 select 'Real Application Clusters', 'Real Application Clusters (RAC)' from dual
                 union all
                 select 'Real Application Testing', 'Database Replay: Workload Capture' from dual
                 union all
                 select 'Real Application Testing', 'Database Replay: Workload Replay' from dual
                 union all
                 select 'Real Application Testing', 'SQL Performance Analyzer' from dual
                 union all
                 select 'Spatial'
                      ,  'Spatial (Not used because this does not differential usage of spatial over locator, which is free)'
                   from dual
                 union all
                 select 'Total Recall', 'Flashback Data Archive' from dual))
  select nvl (fs.name, fe.detailname) as "Name"
       ,  fe.feature_option as "Option"
       ,  fs.version as "Version"
       ,  nvl (fs.currently_used, 'FALSE') as "In Use"
       ,  fs.detected_usages as "Detected"
       ,  to_char (fs.first_usage_date, 'dd.mm.yyyy hh24:mi') as "First Usage"
       ,  to_char (fs.last_usage_date, 'dd.mm.yyyy hh24:mi') as "Last Usage"
       ,  fs.description as "Description"
    from dba_feature_usage_statistics fs, v_feature fe
   where fe.detailname(+) = fs.name
order by nvl (fs.currently_used, 'FALSE') desc, fs.name
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME