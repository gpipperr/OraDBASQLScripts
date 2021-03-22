--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: start a trace in this session
--==============================================================================
-- see http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_monitor.htm#ARPLS67176
--
-- If serial_num is NULL but session_id is specified, a session with a given session_id is traced irrespective of its serial number. If both session_id and serial_num are NULL, the current user session is traced. 
-- It is illegal to specify NULL session_id and non-NULL serial_num. In addition, the NULL values are default and can be omitted. 
--
-- session_id  Client Identifier for which SQL trace is enabled. If omitted (or NULL), the user's own session is assumed.
-- serial_num  Serial number for this session. If omitted (or NULL), only the session ID is used to determine a session.
-- waits       If TRUE, wait information is present in the trace
-- binds       If TRUE, bind information is present in the trace
-- plan_stat   Frequency at which we dump row source statistics. Value should be 'NEVER', 'FIRST_EXECUTION' (equivalent to NULL) or 'ALL_EXECUTIONS'.

-- Start tracing with session_trace_enable => No entry in dba_enabled_traces but Entry in gv$session column SQL_TRACE != 'DISABLED'
--==============================================================================


begin
 dbms_monitor.session_trace_enable(
    session_id   => null,
    serial_num   => null,
    waits        => true,
    binds        => true,
    plan_stat    => null);
 end;
 /

 
-- set Session identifier  and trace over this identifier

--/
 
 
 
 