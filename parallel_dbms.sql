--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: DBMS_PARALLEL chunks in work
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "DBMS_PARALLEL chunks in Work" skip 2

column "Chunks" format a20
column Status format a20

select to_char (count (*)) as "Chunks", status
    from dba_parallel_execute_chunks
group by status
/

ttitle left  "DBMS_PARALLEL Errors" skip 2

column error_message format a100

select task_name
     ,  status
     ,  error_code
     ,  error_message
  from dba_parallel_execute_chunks
 where error_message is not null
/

ttitle off