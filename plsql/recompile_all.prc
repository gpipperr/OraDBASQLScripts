create or replace procedure recompileAll as
  cursor c_objects is
    select owner
          ,object_name
          ,object_type
      from dba_objects
     where status != 'VALID'
       and object_type != 'MATERIALIZED VIEW';

  v_sql_template varchar2(255) := 'alter ##OBJECTTYPE## ##OWNER##.##OBJECT_NAME## compile';
  v_sql          varchar2(512);
begin

  for rec in c_objects
  loop
    v_sql := replace(v_sql_template, '##OBJECTTYPE##', replace(rec.object_type,'BODY',''));
    v_sql := replace(v_sql, '##OWNER##', rec.owner);
    v_sql := replace(v_sql, '##OBJECT_NAME##', rec.object_name);
  
    dbms_output.put_line('-- Info -- call SQL ::' || v_sql);
    begin
      execute immediate v_sql;      
    exception
      when others then
        dbms_output.put_line('-- Info -- call SQL ::' || v_sql || 'Error ::' || sqlerrm);
    end;
  end loop;
end;