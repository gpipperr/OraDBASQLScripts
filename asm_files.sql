--==============================================================================
-- GPI - Gunther Pippèrr 
-- Desc:   all files on an ASM disk group
--==============================================================================
set linesize 130 pagesize 300 

define DG_NAME = '&1'

prompt
prompt Parameter 1 = Data Group Name          => &&DG_NAME.
prompt

ttitle left  "ASM Files on Disk group &&DG_NAME. " skip 2

column file_name   format a30   heading "File|Name"
column file_number format 99999 heading "File|Nr"
column mb_bytes    format 999G999G999 heading "File|MB"

column DUMMY noprint;
compute sum of MB_BYTES on DUMMY;
break on DUMMY;

select null dummy
       ,  f.group_number
       ,  f.file_number
       ,  round (  f.bytes  / 1024  / 1024,  2)  as mb_bytes
       ,  a.name as file_name
    from v$asm_file f, v$asm_alias a, v$asm_diskgroup dg
   where f.file_number = a.file_number
     and f.group_number = a.group_number
     and dg.group_number = f.group_number
     and dg.name like upper ('&&DG_NAME')
order by f.file_number
/

ttitle off

prompt ...
prompt to see all files NOT Opened:
prompt "Script to report the list of files stored in ASM and CURRENTLY NOT OPENED [ID 552082.1]"
prompt ...

clear break
