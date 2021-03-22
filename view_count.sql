--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   count the entries of a table
-- Date:   01.September 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

-- col y new_value OWNER
-- define OWNER=?
-- select case when nvl('&2','NO') = 'NO' then user else '&1' end as  y  from dual;
-- col x new_value TAB_NAME
-- define TAB_NAME=?
-- select case when nvl('&2','NO') != 'NO' then '&2' else '&' end as  x  from dual;

define OWNER   ='&1'
define TAB_NAME='&2'

prompt
prompt Parameter 1 = OWNER            => &&OWNER.
prompt Parameter 2 = Tab or view Name => &&TAB_NAME.
prompt

ttitle left  "Count records of the table &&OWNER..&&TAB_NAME" skip 2

column count_rows   format 9999999  heading "Count|rows"


select /* gpi script lib view_count.sql */ count(*) as count_rows from &&OWNER..&&TAB_NAME 
/ 

prompt
prompt
undef TAB_NAME
undef OWNER

ttitle off