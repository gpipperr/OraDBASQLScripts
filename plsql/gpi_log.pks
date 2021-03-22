CREATE OR REPLACE package gpi_log as

-- +============================================================================
--   NAME:       gpi_log
--   PURPOSE:    Provides error monitoring functionality for  procedures and functions
--                   
-- +============================================================================
  
  -- constant for Error code (Routine return value)
  c_ok                     constant number( 1 )   :=  0;
  c_fatal_error            constant number( 1 )   := -1;
  c_validation_error       constant number( 1 )   := -2;
  
  -- constant for raise_application_error
  c_application_error      constant number( 5 )   := -20000;
  
  -- Error message offset
  c_message_offset         constant number( 2 )   := 11;

  -- constant for character flags
  c_true                   constant varchar2( 1 ) := 'T';
  c_false                  constant varchar2( 1 ) := 'F';

  -- constant for Yes/No-Flag
  c_yes                    constant varchar2( 1 ) := 'Y';
  c_no                     constant varchar2( 1 ) := 'N';

  -- constant fuer standard trace level (used in exception handler tracing)
  c_trace_lvl_1            constant number( 1 )   := 1;
  c_trace_lvl_2            constant number( 1 )   := 2;
  c_trace_lvl_3            constant number( 1 )   := 3;

  -- standard trace schalter ein/aus
  c_trace_on               constant boolean       := true;

  -- constant for Identifikation from  DML-statement
  c_dml_statement_insert   constant varchar2( 3 ) := 'INS';
  c_dml_statement_update   constant varchar2( 3 ) := 'UPD';
  c_dml_statement_delete   constant varchar2( 3 ) := 'DEL';
  
  -- variable for error-messages
  v_errcode NUMBER;
  v_errmsg  VARCHAR2(1000);
  v_errtrc  VARCHAR2(1000);
 
--  +=====================================================================+
--                       Error monitoring
--  +=====================================================================+
  procedure seterror(
 	      p_message  varchar2
  	    , p_modul    varchar2
 	   );
	   
--  +=====================================================================+
--                    tracing with the v$session view
--  +=====================================================================+
  procedure trace_line(
  	      p_routine_name   in   varchar2
 	    , p_trace_level    in   number
 	    , p_trace_msg      in   varchar2
 	    , p_used_ids       in   varchar2 default null
 	   );

	  
--  +=====================================================================+
--                    create the error log tab
--  +=====================================================================+	   
procedure create_error_tab; 

END gpi_log;
/