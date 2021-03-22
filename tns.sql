--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   check Services and tns Settings for the services
-- Date:   09.2013
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 


ttitle 'services configured to use load balancing advisory (lba) features| (from dba_services)'

column name            format a16      heading 'service name' wrap
column created_on      format a20      heading 'created on' wrap
column goal            format a12      heading 'service|workload|management|goal'
column clb_goal        format a12      heading 'connection|load|balancing|goal'
column aq_ha_notifications format a16  heading 'advanced|queueing|high-|availability|notification'

  select name
       ,  to_char (creation_date, 'mm-dd-yyyy hh24:mi:ss') created_on
       ,  goal
       ,  clb_goal
       ,  aq_ha_notifications
    from dba_services
   where     goal is not null
         and name not like 'SYS%'
order by name
/


ttitle 'current service-level metrics|(from gv$servicemetric)'


--break on service_name noduplicates

column service_name    format a15          heading 'service|name' wrap
column inst_id         format 9999         heading 'inst|id'
column beg_hist        format a10          heading 'start time' wrap
column end_hist        format a10          heading 'end time' wrap
column intsize_csec    format 9999         heading 'intvl|size|(cs)'
column goodness        format 999999       heading 'goodness'
column delta           format 999999       heading 'pred-|icted|good-|ness|incr'
column cpupercall      format 99999999     heading 'cpu|time|per|call|(mus)'
column dbtimepercall   format 99999999     heading 'elpsd|time|per|call|(mus)'
column callspersec     format 99999999     heading '# 0f|user|calls|per|second'
column dbtimepersec    format 99999999     heading 'dbtime|per|second'
column flags           format 999999       heading 'flags'

  select sm.inst_id
       ,  sm.service_name
       ,  ds.service_id
       ,  to_char (sm.begin_time, 'hh24:mi:ss') beg_hist
       ,  to_char (sm.end_time, 'hh24:mi:ss') end_hist
       ,  sm.goodness
       ,  sm.flags
       ,  ds.goal
       ,  sm.delta
       ,  sm.dbtimepercall
       ,  sm.callspersec
       ,  sm.dbtimepersec
    from gv$servicemetric sm, dba_services ds
   where     sm.service_name = ds.name
         and ds.goal is not null
order by sm.service_name, sm.inst_id, sm.begin_time
/

prompt ...
prompt ... goodness => indicates how attractive a given instance is with respect to processing the workload that is presented to the service.
prompt ... a lower number is better. this number is internally computed based on the goal (long or short) that is specified for the particular service.
prompt ...
prompt ... predicted goodness incr => the predicted increase in the goodness for every additional session that is routed to this instance
prompt ...
prompt ... flags
prompt ...      0x01 - service is blocked from accepting new connections
prompt ...      0x02 - service is violating the set threshold on some metric
prompt ..       0x04 - goodness is unknown

clear break


ttitle 'current connection distribution over the services'

  select count (*)
       ,  inst_id
       ,  service_name
       ,  username
    from gv$session
   where service_name not like 'SYS%'
group by service_name, inst_id, username
order by 4
/

ttitle 'current connection over the services for each server'

  select count (*)
       ,  inst_id
       ,  service_name
       ,  username
       ,  machine
    from gv$session
   where service_name not like 'SYS%'
group by service_name
       ,  inst_id
       ,  username
       ,  machine
order by 5
/

ttitle 'current services defined but not active? delete script'

column cmd format a100

select 'execute dbms_service.delete_service(''' || name || ''');' as cmd
  from dba_services
 where name not in (select name from gv$active_services)
/

ttitle 'Current Service Name Paramter'

@init service_names


variable ddllob clob

set heading off
set echo off

set long 64000;



declare
   type tockenTab is table of varchar2 (255)
                        index by binary_integer;

   cursor c_sv_value
   is
      select value
        from gv$parameter p, gv$instance v
       where     p.inst_id = v.inst_id
             and name = 'service_names';

   v_param_list    varchar2 (32767);
   v_ddl           varchar (2000) := 'alter system set service_names=##SERVICE_NAME_LIST## scope=both sid=''*'';';
   v_tab_length    binary_integer;
   v_s_array       dbms_utility.lname_array;
   v_a_list        tockenTab;
   v_a_count       pls_integer := 0;
   v_s_mon_found   boolean := false;
begin
   for rec in c_sv_value
   loop
      -- split servicenames in a table
      dbms_utility.comma_to_table (list => rec.value, tablen => v_tab_length, tab => v_s_array);

      -- check for monitoring service
      for i in 1 .. v_tab_length
      loop
         if rtrim (ltrim (upper (v_s_array (i)))) like 'S_MONITORING%'
         then
            v_s_mon_found := true;
         end if;
      end loop;

      if v_s_mon_found = false
      then
         v_tab_length :=
              v_tab_length
            + 1;
         v_s_array (v_tab_length) := 'S_MONITORING';
      end if;

      -- recreate the parameter
      for i in 1 .. v_tab_length
      loop
         if i = 1
         then
            v_param_list := rtrim (ltrim (v_s_array (i)));
         else
            if length (v_param_list || ',' || v_s_array (i)) < 200
            then
               v_param_list := v_param_list || ',' || rtrim (ltrim (v_s_array (i)));
            else
               v_a_count :=
                    v_a_count
                  + 1;
               v_a_list (v_a_count) := v_param_list;
               v_param_list := rtrim (ltrim (v_s_array (i)));
            end if;
         end if;
      end loop;

      v_a_count :=
           v_a_count
         + 1;
      v_a_list (v_a_count) := v_param_list;

      dbms_output.put_line ('Info -- orginal==' || rec.value);


      for i in 1 .. v_a_count
      loop
         if i = 1
         then
            v_param_list := '''' || v_a_list (i);
         else
            v_param_list := v_param_list || ''',''' || v_a_list (i);
         end if;
      end loop;

      v_param_list := v_param_list || '''';
   end loop;

   :ddllob := replace (v_ddl, '##SERVICE_NAME_LIST##', v_param_list);
end;
/

set linesize 130
column cmd format a130

select :ddllob as cmd from dual;

undefine ddllob

set heading on


ttitle off
