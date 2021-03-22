--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get List of Tables with Umlauts
-- Date:   01.September 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 


column owner        format a14     heading "Owner"
column table_name   format a30     heading "Table|name"
column column_name  format a30     heading "Column|name"

ttitle left  "Table and View Names with strange signs like umlauts" skip 2

select t.owner
     , t.view_name    
  from dba_views t 
where regexp_instr(upper(
                             replace (
                                   replace(
                                        replace(
                                         replace(t.view_name,'+','')
                                        ,' ','')
                                   ,'/','')
                             ,'#','')                      
          ),'[^QWERTZUIOPASDFGHJKLYXCVBNM1234567890$_-]') > 0 
union -- may be duplicates , fix
select t.owner
     , t.table_name    
  from dba_tables t 
where regexp_instr(upper(
                             replace (
                                   replace(
                                        replace(
                                         replace(t.table_name,'+','')
                                        ,' ','')
                                   ,'/','')
                             ,'#','')                      
          ),'[^QWERTZUIOPASDFGHJKLYXCVBNM1234567890$_-]') > 0 
order by 1,2   
/  


ttitle left  "Table and View Columns with strange signs like umlauts" skip 2

select t.owner
     , t.table_name
     , t.column_name     
  from dba_tab_columns t 
where regexp_instr(upper(
                             replace ( replace(
                                                    replace(
                                                           replace(t.column_name,'+','')
                                                    ,' ','')
                                         ,'/','')          
                                   ,'#','')
          )
         ,'[^QWERTZUIOPASDFGHJKLYXCVBNM1234567890$_-]') > 0
order by 1,2,3     
/
