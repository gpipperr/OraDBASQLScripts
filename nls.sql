--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   nls settings of the Session and the database
-- Date:   September 2012
--
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "Session NLS Lang Values" skip 2

select sys_context ('USERENV', 'LANGUAGE') as NLS_LANG_Parameter from dual;

ttitle left  "Session NLS Values" skip 2

column parameter format a24 heading "NLS Session Parameter"
column value     format a30 heading "Setting"

select PARAMETER, value
    from nls_session_parameters
order by 1
/

ttitle left  "Database Time Zone" skip 2

select dbtimezone from dual
/

ttitle left  "Session Time Zone" skip 2

select sessiontimezone from dual
/

ttitle left  "Session Time Values" skip 2

select to_char (sysdate, 'dd.mm.yyyy hh24:mi') as "DB Time"
     ,  to_char (current_date, 'dd.mm.yyyy hh24:mi') as "Client Time"
     ,    sysdate
        - current_date
           as "Time gab between client and db"
  from dual
/


ttitle left  "Char set of the database" skip 2
column parameter format a24 heading "NLS DB Character Set"

select PARAMETER, value
    from nls_database_parameters
   where parameter in ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET', 'NLS_LENGTH_SEMANTICS','NLS_LANGUAGE','NLS_TERRITORY')
order by 2
/

ttitle left  "NLS_LENGTH_SEMANTICS of the database" skip 2

show parameter NLS_LENGTH_SEMANTICS

prompt
prompt ... if NLS_LENGTH_SEMANTICS is byte new varchar2 columns will be defaulted to varchar2( xx byte)
prompt


ttitle off