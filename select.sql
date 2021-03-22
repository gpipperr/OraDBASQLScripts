--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   query some records from the table as list
-- Parameter 1: Name of the table
--
-- Source see http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_sql.htm#i996897
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define TAB_NAME = '&1'

prompt
prompt Parameter 1 = Tab Name         => &&TAB_NAME.
prompt

set serveroutput on

/*
from DBA_TAB_COLS 
decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
        2, decode(c.scale, null,
                  decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                  'NUMBER'),
        8, 'LONG',
        9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
        12, 'DATE',
        23, 'RAW', 24, 'LONG RAW',
        58, nvl2(ac.synobj#, (select o.name from obj$ o
                 where o.obj#=ac.synobj#), ot.name),
        69, 'ROWID',
        96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
        100, 'BINARY_FLOAT',
        101, 'BINARY_DOUBLE',
        105, 'MLSLABEL',
        106, 'MLSLABEL',
        111, nvl2(ac.synobj#, (select o.name from obj$ o
                  where o.obj#=ac.synobj#), ot.name),
        112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
        113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
        121, nvl2(ac.synobj#, (select o.name from obj$ o
                  where o.obj#=ac.synobj#), ot.name),
        122, nvl2(ac.synobj#, (select o.name from obj$ o
                  where o.obj#=ac.synobj#), ot.name),
        123, nvl2(ac.synobj#, (select o.name from obj$ o
                  where o.obj#=ac.synobj#), ot.name),
        178, 'TIME(' ||c.scale|| ')',
        179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
        180, 'TIMESTAMP(' ||c.scale|| ')',
        181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
        231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
        182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
        183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
              c.scale || ')',
        208, 'UROWID',
        'UNDEFINED'),
       decode(c.type#, 111, 'REF'),

*/

declare
   type curtype is ref cursor;

   src_cur              curtype;
   v_cursor_id          number;
   v_colType_var        varchar2 (50);
   v_colType_num        number;
   v_colType_date       date;
   v_colType_interval   interval day to second;

   v_tab_desc           dbms_sql.desc_tab;


   v_col_count          number;


   v_sql                varchar2 (1000) := 'select * from ( &&TAB_NAME. )  where rownum < 4';
begin
   dbms_output.put_line (rpad ('=', 40, '='));
   dbms_output.put_line (rpad (rpad ('-', 10, '-') || ' &&tab_name ', 40, '-'));
   dbms_output.put_line (rpad ('=', 40, '='));

   -- open cursor for the sql statement
   open src_cur for v_sql;

   -- switch from native dynamic sql to dbms_sql package.
   v_cursor_id := dbms_sql.to_cursor_number (src_cur);
   dbms_sql.describe_columns (v_cursor_id, v_col_count, v_tab_desc);

   -- define columns.
   for i in 1 .. v_col_count
   loop
      if v_tab_desc (i).col_type = 2
      then
         dbms_sql.define_column (v_cursor_id, i, v_colType_num);
      elsif v_tab_desc (i).col_type = 12
      then
         dbms_sql.define_column (v_cursor_id, i, v_colType_date);
      else
         dbms_sql.define_column (v_cursor_id
                               ,  i
                               ,  v_colType_var
                               ,  50);
      end if;
   end loop;

   -- fetch rows with dbms_sql package.
   while dbms_sql.fetch_rows (v_cursor_id) > 0
   loop
      for i in 1 .. v_col_count
      loop
         dbms_output.put (rpad (v_tab_desc (i).col_name, 30) || ' => ');

         if (v_tab_desc (i).col_type = 1)
         then
            dbms_sql.column_value (v_cursor_id, i, v_colType_var);
            dbms_output.put_line (v_colType_var);
         elsif (v_tab_desc (i).col_type = 2)
         then
            dbms_sql.column_value (v_cursor_id, i, v_colType_num);
            dbms_output.put_line (v_colType_num);
         elsif (v_tab_desc (i).col_type in (12))
         then --, 178, 179, 180, 181, 231
            dbms_sql.column_value (v_cursor_id, i, v_colType_date);
            dbms_output.put_line (v_colType_date);
         -- elsif (v_tab_desc(i).col_type = 183) then
         --   dbms_sql.column_value(v_cursor_id, i, v_colType_interval);
         --   dbms_output.put_line(to_char(v_colType_interval));
         else
            dbms_output.put_line ('unsupported Datatype ::' || v_tab_desc (i).col_type);
         end if;
      end loop;

      dbms_output.put_line (rpad ('=', 40, '='));
   end loop;

   -- Close the cursor
   dbms_sql.close_cursor (v_cursor_id);
end;
/