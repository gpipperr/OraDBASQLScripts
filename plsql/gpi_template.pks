create or replace package gpi$template is

-- +============================================================================
--   NAME:       gpi$template
--   PURPOSE:    template for new packages
--                   
-- +============================================================================
 
   -- exception handling
   g_pck   CONSTANT VARCHAR2 (30) := 'gpi$template';

   EX_GPERRORS      EXCEPTION;
   PRAGMA EXCEPTION_INIT (EX_GPERRORS, -20100);
   g_emerrors       VARCHAR2 (100) := 'An error occured. Please view the ERRORS-table for more information.';

   -- global variables 
   
   
 -- +===========================================================+
 --  Procedure : procedure one
 -- +===========================================================+
  procedure one;
  
end gpi$template;
/
