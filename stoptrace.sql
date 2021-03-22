--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: stop a trace in this session
--==============================================================================
-- see http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_monitor.htm#ARPLS67176
--
-- session_id 	Database Session Identifier for which SQL trace is disabled
-- serial_num 	Serial number for this session
--==============================================================================



-- Start tracing with session_trace_enable => No entry in dba_enabled_traces but Entry in gv$session column SQL_TRACE != 'DISABLED'
begin
dbms_monitor.session_trace_disable(
   session_id      => null,
   serial_num      => null);
end;
/


-- set Session identifier  and trace over this identifier
--begin
-- dbms_monitor.client_id_trace_disable ('GPI_TRACE_SESSION');
--end;
--/
