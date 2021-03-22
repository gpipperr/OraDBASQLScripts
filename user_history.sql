--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  get some static information for the login behavior of this user -  Parameter 1 - Name of the user
-- Date:   November 2013
-- in work
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set verify off
set linesize 130 pagesize 300 

@select DBA_HIST_ACTIVE_SESS_HISTORY
