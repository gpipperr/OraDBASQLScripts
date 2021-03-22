--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report for the db link Usages in the database
-- Date:   September 2015
--
--==============================================================================

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_link_usage.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off
SET linesize 250 pagesize 2000 

spool &&SPOOL_NAME

---set markup html ON ENTMAP OFF

define SEARCH_HOST='GPI'


declare
   cursor c_links
   is
      select owner,db_link
        from dba_db_links  
	   where upper(HOST) like '%&&SEARCH_HOST%'
	order by 1;

	v_count pls_integer:=0;	 
		
begin
    dbms_output.put_line ('<html><body>');
	dbms_output.put_line ('<table border=1>');
    dbms_output.put_line ('<tr>');
    dbms_output.put_line ('<td>'
                        || 'OWNER'
                        || ' </td><td>'
                        || 'TYPE'
                        || ' </td><td>'
                        || 'Object Name'
						|| ' </td><td>'
                        || 'Line'
                        || ' </td><td>'
                        || 'CODE'
						||'</td>');
    dbms_output.put_line ('</tr>');	
	
	for rec in c_links
	loop
	  v_count:=0;
	  dbms_output.put_line ('<tr>');
	  dbms_output.put_line ('<td colspan=2>');	  
	  dbms_output.put_line ('Owner:' || upper (rec.owner));
	  dbms_output.put_line ('</td>');
	  dbms_output.put_line ('<td colspan=3>');	  
	  dbms_output.put_line ('DB Link Usage for Link:' || upper (rec.db_link));
	  dbms_output.put_line ('</td>');
	  dbms_output.put_line ('</tr>');
      -- check source code
	  for srec in (select owner
                        , name
                        , type
						, line
                        , text
                     from dba_source
                    where upper (text) like '%' || upper (rec.db_link) || '%' order by owner, name ,line)
      loop
		dbms_output.put_line ('<tr>');
        dbms_output.put_line (   ' <td>'
                               || srec.owner
                               || ' </td><td>'
                               || srec.type
                               || ' </td><td>'
                               || srec.name
							   || ' </td><td>'
                               || srec.line
                               || ' </td><td>'
                               || substr (srec.text
                                        , 1
                                        , 80
                                         )
							    ||'</td>');
        v_count:=v_count+1;
		dbms_output.put_line ('</tr>');										 
      end loop;	  
	  
	  -- check materialsed views
	  for srec in (  select owner
	                     ,  mview_name as name 
						 , 'MV' as type
						 , 'n/a' as line
						 , query as text
	                 from dba_mviews v 
					where upper(master_link)=upper (rec.db_link) order by owner,mview_name )
		loop
		dbms_output.put_line ('<tr>');
        dbms_output.put_line (   ' <td>'
                               || srec.owner
                               || ' </td><td>'
                               || srec.type
                               || ' </td><td>'
                               || srec.name
							   || ' </td><td>'
                               || srec.line
                               || ' </td><td>'
                               || substr (srec.text
                                        , 1
                                        , 250
                                         )
							    ||'</td>');
        v_count:=v_count+1;
		dbms_output.put_line ('</tr>');										 
      end loop;	      	  
	  dbms_output.put_line ('<tr>');	    
	  dbms_output.put_line ('<td colspan=4>');
	  dbms_output.put_line ('DB Link Usage for this link:' || to_char(v_count));
	  dbms_output.put_line ('</td>');
	  dbms_output.put_line ('</tr>');
	end loop;
	dbms_output.put_line ('</table>');
	dbms_output.put_line ('</body></html>');
end;
/



---set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
--host &&SPOOL_NAME

