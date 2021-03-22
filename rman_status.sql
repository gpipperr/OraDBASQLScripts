--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the status of the last backup in the database
--==============================================================================
set linesize 130 pagesize 300 

column input_type               format a30
column status                   format a12
column time_taken_display       format a10 heading "Time|used"
column output_bytes_display     format a10 heading "Byte|output"
column btatus                   format a20 heading "Metric|Status"
column btype                    format a20 heading "Backup|Type"
column CONTROLFILE_INCLUDED     format 99 heading "Controlf.|Count"
column start_time                         heading "Start|Time"
column INCREMENTAL_LEVEL        format 99 heading "Le|vel"
column session_recid                      heading "Session|recid"


alter session set nls_date_format='dd.mm.yyyy hh24:mi'
/

--break on session_recid

select input_type
       ,  status
       ,  start_time
       ,  time_taken_display
       ,  output_bytes_display
       ,  case
             when (    (input_type in ('ARCHIVELOG'))
                   and (  trunc (sysdate)
                        - trunc (start_time) > 0))
             then
                'ERROR'
             else
                case
                   when (  trunc (sysdate)
                         - trunc (start_time) between 7
                                                  and 14)
                   then
                      case when (input_type like ('CONTROLFILE%')) then 'OK' else 'ERROR' end
                   when (  trunc (sysdate)
                         - trunc (start_time) > 14)
                   then
                      case when (input_type like ('CONTROLFILE%')) then 'OK' else 'WARNING' end
                   else
                      case when (status in ('COMPLETED')) then 'OK' when (status in ('FAILED')) then 'ERROR' else 'WARNING' end
                end
          end
             as BStatus
       ,  '-' as backup_type
       ,  controlfile_included
       ,  input_type_text || ' ' || INCREMENTAL_LEVEL as input_type_text
    from (  select jd.SESSION_KEY
                 ,  trim (jd.input_type || ' ' || ' Key: ' || jd.SESSION_KEY) as input_type
                 ,  trim (jd.input_type) as input_type_text
                 ,  max (sd.INCREMENTAL_LEVEL) as INCREMENTAL_LEVEL
                 ,  sum (decode (sd.CONTROLFILE_INCLUDED,  'YES', 1,  'NO', 0,  0)) as controlfile_included
                 ,  jd.status
                 ,  jd.start_time
                 ,  ltrim (rtrim (jd.time_taken_display)) as time_taken_display
                 ,  ltrim (rtrim (jd.output_bytes_display)) as output_bytes_display
                 ,  rank () over (partition by trim (jd.input_type) order by jd.SESSION_KEY desc) as rang
              from v$rman_backup_job_details jd, v$backup_set_details sd
             where     sd.SESSION_KEY = jd.SESSION_KEY
                   and sd.SESSION_RECID = jd.SESSION_RECID
                   and sd.SESSION_STAMP = jd.SESSION_STAMP
          --and 1 = (select count(inst_id) from gv$instance)
          group by jd.SESSION_KEY
                 ,  trim (jd.input_type)
                 ,  trim (jd.input_type || ' ' || ' Key: ' || jd.SESSION_KEY)
                 ,  jd.status
                 ,  jd.start_time
                 ,  jd.time_taken_display
                 ,  jd.output_bytes_display)
   where rang < 4
order by SESSION_KEY
/

--clear break


prompt ... Errors:

select session_key
       ,  start_time
       ,  end_time
       ,  status
       ,  input_type
       ,  time_taken_display
       ,  output_bytes_display
    from v$rman_backup_job_details
   where     start_time >=   sysdate - 8
         and (   status like '%fail%'
              or status like '%error%%')
order by start_time
/


--==============================================================================
-- variante A 
--   select jd.session_recid
--               , jd.input_type ||' '||sd.INCREMENTAL_LEVEL as input_type
--                   , sd.INCREMENTAL_LEVEL
--                   , BACKUP_TYPE
--                   , jd.status
--                   , jd.start_time
--                   , jd.time_taken_display
--                   , jd.output_bytes_display                     
--                   , sum(decode(sd.CONTROLFILE_INCLUDED,'YES',1,0)) as CONTROLFILE_INCLUDED
--                   , sum(PIECES) as PIECES
--               , rank() over (partition by jd.input_type ||' '||sd.INCREMENTAL_LEVEL order by jd.start_time desc) as rang
--            from  v$rman_backup_job_details jd
--                    ,v$backup_set_details      sd
--              where sd.SESSION_KEY = jd.SESSION_KEY                 
--             -- and 1=(select count(inst_id) from gv$instance)              
--              group by jd.session_recid
--                  , jd.input_type ||' '||sd.INCREMENTAL_LEVEL
--                       , sd.INCREMENTAL_LEVEL
--                       , BACKUP_TYPE
--                       , jd.status
--                      , jd.start_time
--                      , jd.time_taken_display
--                      , jd.output_bytes_display            
--==============================================================================