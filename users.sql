--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the users of the database
-- Date:   September 2013
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 

variable PUSERNAME varchar2(32)

prompt
prompt Parameter 1 = User  Name          => &&USER_NAME.
prompt

begin
 if length('&&USER_NAME.') < 1 then
   :PUSERNAME:='%';
 else
   :PUSERNAME:='&&USER_NAME.'||'%';
 end if;
end;
/



ttitle left  "Default Table space" skip 2

column default_tablespace  format a20 heading "Default Table|space"

SELECT property_value as default_tablespace
  FROM database_properties
WHERE property_name = 'DEFAULT_PERMANENT_TABLESPACE'
/

prompt ... to set the default tablespace : alter database default tablespace <tablespace name>;
prompt

ttitle left  "User information" skip 2

column username         format a24 heading "User Name"
column account_status   format a20 heading "Status"
column profile          format a30 heading "Profil"
column created          format a16 heading "Create Date"

select username
	,  account_status 
    ,  default_tablespace
	,  profile
	,  to_char(CREATED,'dd.mm.yyyy hh24:mi') as created	
 from dba_users
where username like upper(:PUSERNAME)
  --and account_status='LOCKED'
order by username
/

ttitle off

prompt ... to unlock the user    : alter user <name> account unlock;
prompt ... to set the tablespace : alter user <name> default tablespace <tablespace name>;

--undef variables ---

undefine PUSERNAME 

---------------------
set verify on
