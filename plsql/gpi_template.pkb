create or replace package body  gpi$template  is

 -- +===========================================================+
 --  Procedure : procedure one
 -- +===========================================================+
  procedure one;
  is
   v_routine_name   VARCHAR2 (50) :=    g_pck  || '.one';

   begin
	gpi_log.trace_line (v_routine_name, gpi_log.c_trace_lvl_2, 'proc start');
    
     -- do something
	
	gpi_log.trace_line (v_routine_name, gpi_log.c_trace_lvl_2, 'proc end');
	
  exception
      when ex_emerrors
      then
         raise_application_error (-20100, g_emerrors);
      when others
      then
         gpi_log.v_errcode := gpi_log.c_application_error;
         gpi_log.v_errmsg :=
               '@'
            || v_routine_name
            || ': '
            || sqlerrm;
         gpi_log.v_errtrc := sqlerrm;

         gpi_log.seterror (p_message => gpi_log.v_errmsg, p_modul => v_routine_name);
        
		gpi_log.trace_line (v_routine_name, gpi_log.c_trace_lvl_1, gpi_log.v_errtrc);
        raise_application_error (-20100,   g_emerrors|| gpi_log.v_errmsg);
  
  end one;
  
begin
  
  -- Initialization
  null;
  
end  gpi$template ;
/
