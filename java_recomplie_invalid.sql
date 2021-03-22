-- --
--
--
-- ---

set serveroutput on

----------

select count(*),owner 
  from dba_objects 
 where status != 'VALID' 
  and Object_type='JAVA CLASS'
  group by owner
/

---------- 

declare
 cursor c_resolve is 
   select 'alter java class '|| owner ||'.' ||'"'||object_name||'" resolve' as command 
     from dba_objects 
    where status != 'VALID' 
      and Object_type='JAVA CLASS';
  begin
  for i in 1 .. 10
  loop
     for rec in  c_resolve 
     loop
        begin
          execute immediate rec.command;
          dbms_output.put_line(' -- Info execute ::'||rec.command);
        exception
         when others then
           dbms_output.put_line(' -- Error execute ::'||rec.command ||' :: SQLERRM:'||SQLERRM);
        end;     
      end loop;
  end loop;
end;
/

----------

select count(*),owner 
  from dba_objects 
 where status != 'VALID' 
  and Object_type='JAVA CLASS'
  group by owner
/
