--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   read the alert log of the database over the adrci alert.xml
--===============================================================================
set linesize 130 pagesize 300  pages 0

define SEARCH_TEXT    = '&1'

prompt
prompt Parameter 1 = SEARCH_TEXT  => &&SEARCH_TEXT.
prompt

set serveroutput on;

column  log_date         format a20
column  message_text     format a95

select substr (originating_timestamp, 1, 15) as log_date, message_text
  from x$dbgalertext
 where     originating_timestamp > (  sysdate
                                    - 10)
       and message_text like '%&&SEARCH_TEXT.%'
/