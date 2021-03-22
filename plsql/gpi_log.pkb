CREATE OR REPLACE package body gpi_log as

-- +============================================================================
--   NAME:       gpi_log
--   PURPOSE:    Provides error monitoring functionality for  procedures and functions
--                   
-- +============================================================================
 
  
--
-- INTERNAL DECLARATIONS
--
  c_pck   constant varchar2( 30 ) := 'gpi_log';
--    
-- PROCEDURES
--

--  +=====================================================================+
--   Server Side Trace with control of the output via Trace Level
--   The Trace views will be realised through the view v$session:
--   In the column ACTION the information <PackageName>.<Routine> is visibale
--   In the column CLIENT_INFO runtime information
--   If a error occured: CLIENT_INFO = error code
--   Trace-Level
--         Level =   1 : Exception occourd
--         Level =   2 : Start, Ende of a Routine
--         Level =   3 : Steps in a Routine
--  +=====================================================================+
 
  procedure trace_line(
 	      p_routine_name   in   varchar2
	    , p_trace_level    in   number
 	    , p_trace_msg      in   varchar2
 	    , p_used_ids       in   varchar2 default null
 	   )
  is
 	 c_routine_name   constant varchar2( 50 ) := c_pck || '.trace_line ';
	 --
  begin
 	      --
 	      -- Ist trace eingeschaltet ?
 	      if gpi_log.c_trace_on then
 	         -- setzen Aktion=Routine
 	         DBMS_APPLICATION_INFO.set_action( p_routine_name );
 	         -- setzen Client Info
 	         DBMS_APPLICATION_INFO.set_client_info( SUBSTR( SUBSTR( p_trace_msg, 1, gpi_log.c_message_offset ) || p_used_ids
 	                                                      , 1
 	                                                      , 64
 	                                                      )
 	                                              );
 	      end if;
 	   --
 	   exception
	      when others then
 	         gpi_log.seterror( p_message      => 'Error trace Client ' || p_routine_name || ' :: ' || p_routine_name
 	                         , p_modul        => c_routine_name
 	                        );
  end trace_line;
 	
 	
--  +=====================================================================+
--  seterror
--   fill error table
--  +=====================================================================+

   procedure seterror(
 	      p_message  varchar2
  	    , p_modul    varchar2
 	   )
   as
      pragma autonomous_transaction;

      v_sqlcode   varchar2( 255 )  := SQLCODE;
      v_sqlerrm   varchar2( 2000 ) := SQLERRM;
	  v_sql_text  varchar2(2000);	  
   begin
    -- using dynamic sql -table may not exists at package creation time
	v_sql_text:=' insert into gpi$logerrors
                  ( errorid
                  , code
                  , modul
                  , text
				  , error_time
                  )
           values ( seq_gpi$logerrors.nextval
                  , :1
                  , :2 
                  , :3
				  , sysdate
                  )';
				  
    execute immediate v_sql_text using  v_sqlcode,  p_modul, p_message;
	
	commit;
	
   end seterror;

--  +=====================================================================+
--    create_error_tab
--    create the error tab
--  +=====================================================================+

  procedure create_error_tab
  as
  
	v_sql_tab1  varchar2(2000):='create table gpi$logerrors ( 
							  errorid number(19)
							, code  varchar(8)
							, modul varchar2(120) 
							, text  varchar2(4000)
							, error_time date default sysdate
						)';
	
	v_sql_tab2 varchar2(2000):='create unique index idx_gpi$logerrors_pk on gpi$logerrors(errorid)';
	
	v_sql_tab3 varchar2(2000):='alter table gpi$logerrors add constraint pk_gpi$logerrors primary key (errorid) enable validate';
	
	v_sql_seq  varchar2(1000):='create sequence seq_gpi$logerrors';	
    
	v_count pls_integer;
  
  begin
  
    -- check if table exists
	select count(*) into v_count from user_tables where table_name = 'GPI$LOGERRORS' ;
  
	-- create the error log table
	if v_count < 1 then 
		execute immediate v_sql_tab1;
		execute immediate v_sql_tab2;
  		execute immediate v_sql_tab3;	
	end if;
	
	-- check for the sequence
	select count(*) into v_count from user_sequences where sequence_name = 'SEQ_GPI$LOGERRORS' ;
	if v_count < 1 then 
		execute immediate v_sql_seq;
	end if;
	       
  end create_error_tab;  
 
begin
	-- check at start-up of package if error table exists
	-- if not create the table and the sequence
	gpi_log.create_error_tab;   
	
end gpi_log;
/

