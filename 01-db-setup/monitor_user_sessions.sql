-- create a log table to capture all connection to the database over v$session
-- benfit, capture also none active sessions
--
-- Grant as SYS User  grant select on sys.v_$session to <owner_of_the_package> like system
--


spool create_log_session_table.log

 create table log_user_sessions (
     id        number(10) not null
  ,  username  varchar(32)
  ,  osuser    varchar(48)
  ,  machine   varchar(64)
  ,  program   varchar2(64)
  ,  action    varchar(32)
  ,  terminal  varchar(64)
  ,  logon_time      date
  ,  service_name    varchar(64)
  ,  module          varchar(48)
  ,  count_connects  number(5)
  ,  active_connects number(5)
  ,  snaptime        date not null
 )
 tablespace SYSAUX
 /
 
-- add pk

create unique index log_user_sessions_pk1 on log_user_sessions (id) logging tablespace SYSAUX;
alter table log_user_sessions add ( constraint log_user_sessions_pk1  primary key (id)   using index  tablespace SYSAUX );

--

comment on table  log_user_sessions           is 'Log the connected user to the database for connection statistic';
comment on column log_user_sessions.module    is 'Name of the currently executing module as set by the DBMS_APPLICATION_INFO.SET_MODULE procedure';
comment on column log_user_sessions.username  is 'Oracle User name';
comment on column log_user_sessions.machine   is 'Client operating system machine name';
comment on column log_user_sessions.program   is 'Name of the operating system program';
comment on column log_user_sessions.count_connects  is 'Count of actual connection at this time';
comment on column log_user_sessions.active_connects is 'Count of connection at this time with active state';
comment on column log_user_sessions.snaptime        is 'Snaptime';
comment on column log_user_sessions.service_name    is 'Name of the DB Service';
comment on column log_user_sessions.logon_time      is 'Logon time of the usersession';
comment on column log_user_sessions.terminal        is 'Operating system terminal name';
comment on column log_user_sessions.osuser          is 'OS user name of the user client session';
comment on column log_user_sessions.action          is 'Name of the currently executing action as set by the DBMS_APPLICATION_INFO.SET_ACTION procedure';


-- 
create sequence log_user_sessions_seq minvalue 1 cache 20;

--
-- Create the log procedure
-- 
create or replace procedure p_log_user_sessions
authid current_user
is
/******************************************************************************
   NAME:       p_log_user_sessions
   PURPOSE:    Read the V$session and record the connect users infos for 
               statistic purpose and ot see who is working with the DB

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24.09.2015  GPI             1. Created this procedure.

   NOTES:

******************************************************************************/
   -- declae table for the resuls
   type t_session_tab is table of log_user_sessions%rowtype;
   -- define
   v_sessiontab                  t_session_tab;
   -- weak cursor
   -- c_cur                         sys_refcursor;
   -- hard cursor
   cursor c_cur is select log_user_sessions_seq.nextval as id    
                            ,  username 
                            ,  osuser   
                            ,  machine  
                            ,  program  
                            ,  action   
                            ,  terminal 
                            ,  logon_time     
                            ,  service_name   
                            ,  module         
                            ,  count_connects 
                            ,  active_connects
                            ,  snaptime       
                       from ( select  username
                                   ,  osuser
                                   ,  machine         
                                   ,  program
                                   ,  terminal   
                                   ,  action    
                                   ,  module 
                                   ,  trunc(logon_time,'MI')   as logon_time
                                   ,  service_name
                                   ,  count(*) as count_connects
                                   ,  sum(decode(s.status,'ACTIVE', 1,0)) as active_connects
                                   ,  sysdate as snaptime
                             from v$session s 
                            where username is not null and username not in ('DBSNMP')
                            group by username
                                   ,  osuser
                                   ,  machine         
                                   ,  program
                                   ,  terminal   
                                   ,  action    
                                   ,  module 
                                   ,  trunc(logon_time,'MI')   
                                   ,  service_name);
begin
   -- Cursor get result set
   open c_cur;
   fetch c_cur
   bulk collect into v_sessiontab;
   close c_cur;

   dbms_output.put_line ('--Info :: Cursor fetch  : ' || v_sessiontab.count);

   begin
      -- execute immedate update
      forall i in 1 .. v_sessiontab.count save exceptions
         insert into log_user_sessions values v_sessiontab (i);
   exception
      when others
      then
         for idx in 1 .. sql%bulk_exceptions.count
         loop
            dbms_output.put_line (   '-- Error :: '
                                  || sql%bulk_exceptions (idx).error_index
                                  || ': '
                                  || sql%bulk_exceptions (idx).error_code);
         end loop;
   end;

   commit;

   end;
/

show errors

-- create the job to record the data every 10 Minutes
declare
    jobno   number;
begin
    dbms_job.submit
       (job  => jobno
       ,what => 'begin  
    p_log_user_sessions; /* Job to get statistic db connected users  - GPI '||to_char(sysdate,'dd.mm.yyyy')||'*/
end;'
       ,next_date =>  trunc(sysdate,'HH24')  + (1/24) --to_date('24.09.2015 09:10','dd.mm.yyyy hh24:mi') 
       ,interval  => 'trunc(sysdate,''mi'') + (1/(24*60)) * 10');
    commit;
 end;
 /

 
spool off

-- Query Examples

select   count (*)
       , l.username
       , l.osuser
       , l.machine
       , l.program
       , l.module
       , trunc (sysdate, 'HH24')
       , min (l.logon_time) as first_login
       , max (l.logon_time) as last_login
    from log_user_sessions l
group by osuser, l.program, l.username, l.module, l.machine, trunc (sysdate, 'HH24')
order by l.osuser
/
---

 

