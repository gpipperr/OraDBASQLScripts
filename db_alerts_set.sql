--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: set the threshold of a metric
-- Work in Progress
--==============================================================================

/*
METRICS_NAME	VARCHAR2(64)	 	Metrics name
WARNING_OPERATOR	VARCHAR2(12)	 	Relational operator for warning thresholds:
GT
EQ
LT
LE
GE
CONTAINS
NE
DO NOT CHECK
DO_NOT_CHECK
WARNING_VALUE	VARCHAR2(256)	 	Warning threshold value
CRITICAL_OPERATOR	VARCHAR2(12)	 	Relational operator for critical thresholds:
GT
EQ
LT
LE
GE
CONTAINS
NE
DO NOT CHECK
DO_NOT_CHECK
CRITICAL_VALUE	VARCHAR2(256)	 	Critical threshold value
OBSERVATION_PERIOD	NUMBER	 	Observation period length (in minutes)
CONSECUTIVE_OCCURRENCES	NUMBER	 	Number of occurrences before an alert is issued
INSTANCE_NAME	VARCHAR2(16)	 	Instance name; NULL for database-wide alerts
OBJECT_TYPE	VARCHAR2(64)	 	Object type:
SYSTEM
SERVICE
EVENT_CLASS
TABLESPACE
FILE
OBJECT_NAME	VARCHAR2(513)	 	Name of the object for which the threshold is set
STATUS	VARCHAR2(7)	 	Indicates whether the threshold is applicable on a valid object (VALID) or not (INVALID)

DBMS_SERVER_ALERT.SET_THRESHOLD(
		metrics_id => DBMS_SERVER_ALERT.BLOCKED_USERS,
		warning_operator => DBMS_SERVER_ALERT.OPERATOR_GT,
		warning_value => '0',
		critical_operator => NULL,
		critical_value => NULL,
		observation_period => 5,
		consecutive_occurrences => 5,
		instance_name => v_instance,
		object_type => DBMS_SERVER_ALERT.OBJECT_TYPE_SESSION,
		object_name => NULL
		
		
*/

declare
   cursor c_metrics (p_instance_name varchar2)
   is
      select metrics_id
           ,  object_type
           ,  object_name
           ,  instance_name
        from table (dbms_server_alert.view_thresholds)
       where instance_name = p_instance_name;

   v_instance                  varchar2 (32);
   v_warning_operator          binary_integer;
   v_warning_value             varchar2 (32);
   v_critical_operator         binary_integer;
   v_critical_value            varchar2 (32);
   v_observation_period        binary_integer;
   v_consecutive_occurrences   binary_integer;
begin
   select instance_name into v_instance from v$instance;

   for rec in c_metrics (p_instance_name => 'TSTPBLM1')
   loop
      sys.dbms_output.put_line ('-- Info - read the Metric : ' || rec.metrics_id);
      dbms_server_alert.get_threshold (metrics_id  => rec.metrics_id
                                     ,  warning_operator => v_warning_operator
                                     ,  warning_value => v_warning_value
                                     ,  critical_operator => v_critical_operator
                                     ,  critical_value => v_critical_value
                                     ,  observation_period => v_observation_period
                                     ,  consecutive_occurrences => v_consecutive_occurrences
                                     ,  instance_name => rec.instance_name
                                     ,  object_type => rec.object_type
                                     ,  object_name => rec.object_name);

      if v_warning_value != null
      then
         sys.dbms_output.put_line ('-- Info - unset the Metric : ' || rec.metrics_id);
         dbms_server_alert.set_threshold (metrics_id  => rec.metrics_id
                                        ,  warning_operator => null
                                        ,  warning_value => null
                                        ,  critical_operator => null
                                        ,  critical_value => null
                                        ,  observation_period => null
                                        ,  consecutive_occurrences => null
                                        ,  instance_name => rec.instance_name
                                        ,  object_type => rec.object_type
                                        ,  object_name => rec.object_name);
      end if;

      commit;
   end loop;
end;
/