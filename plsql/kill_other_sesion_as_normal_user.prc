create or replace procedure kill_other_session(   p_sid      in number
                                                , p_serial#  in number
                                                , p_inst_id  in number   default null
                                                , p_comment  in varchar2 default null
 
)
AUTHID DEFINER

-- =============================================================
-- Procedure kill_other_session
-- Kill as normal user a session in the oracle database over this procedure
-- User need no special rights to execute this procedure
--
-- grant rights over role:
--  create role kill_other_session;
--  grant execute on kill_other_session to kill_other_session;
--  grant kill_other_session to <user_with_kill_rights>;
-- =============================================================

is
 
  v_user          varchar2(512);
  v_kill_message  varchar2(4000);
   
  v_sql      sys.dbms_sql.varchar2a;
  v_cursor   number;
  v_result   pls_integer;
  v_sys_user_id number;
    
begin
   
    -- get the sys user id
    select user_id into v_sys_user_id
      from sys.all_users
     where username = 'SYS';
    

    -- get user and remember some details 
    -- to help to identif the user
    v_user :=sys_context('userenv','SESSION_USER') 
             ||' from the PC '||sys_context('userenv','OS_USER') 
             ||'('||sys_context('userenv','TERMINAL')||')';
    
    
    v_kill_message:='User '|| v_user 
	                ||' try to initiate a kill with sys.kill_other_session of this session :: SID:'||p_sid
					||', Serial:'||p_serial#
					||' - InstID:'||nvl(p_inst_id,userenv('instance'))
					||' - Comment:'||nvl(p_comment,'n/a');
    
        -- log the kill into  the alert file of the database
    sys.dbms_system.ksdwrt ( sys.dbms_system.alert_file, '-- Info : '||v_kill_message);
      
    -- show output
    dbms_output.put_line('-- Info : ----------------------------');
    dbms_output.put_line('-- Info : '||v_kill_message );
    
      
    -- check for RAC    
    -- check if the session exists 
    -- and if the session is not a DB Prozess ( BACKGROUND session!) 
    -- to avoid chrash of the instance!
    if p_inst_id is null then
        for rec in ( select 'x'
                      from sys.gv_$session
                     where sid     = p_sid
                       and serial# = p_serial#
                       and inst_id = userenv('instance')
                       and type != 'BACKGROUND')
        loop
            v_sql(1) := 'alter system kill session ''' || p_sid || ',' || p_serial# || '''';            
        end loop;    
    else
        for rec in ( select 'x'
                      from sys.gv_$session
                     where sid     = p_sid
                       and serial# = p_serial#
                       and inst_id = p_inst_id 
                       and type != 'BACKGROUND')
        loop
            v_sql(1) := 'alter system kill session ''' || p_sid || ',' || p_serial# || ',@' || p_inst_id || '''';           
        end loop;
    end if;
    
    -- check if we found the session
    if v_sql.count > 0 then
         
        -- execute the kill command:             
             
        -- get cursor
        v_cursor := sys.dbms_sys_sql.open_cursor;
    
        -- parse the statement
        sys.dbms_sys_sql.parse_as_user (
              c          => v_cursor
            , statement  => v_sql
            , lb         =>  1
            , ub         => v_sql.count
            , lfflg      => true
            , language_flag => sys.dbms_sys_sql.native
            , userid        => v_sys_user_id );
        
        -- exectute
        v_result := sys.dbms_sys_sql.execute(v_cursor);
        
        -- close the cursor
        sys.dbms_sys_sql.close_cursor( v_cursor );
        
        dbms_output.put_line('-- Info : Kill of the session is requested - please check status of the session');
        sys.dbms_system.ksdwrt ( sys.dbms_system.alert_file, '-- Info ::kill Session with kill_other_session initiated');
        
    else
        dbms_output.put_line('-- Error: ----------------------------');
        dbms_output.put_line('-- Error: Session to kill not found or is BACKGROUND session!' );      
        dbms_output.put_line('-- Error: ----------------------------');
        sys.dbms_system.ksdwrt ( sys.dbms_system.alert_file, '-- Info : kill Session to kill not extis or is BACKGROUND session (not allowed!)');
    end if;


    dbms_output.put_line('-- Info : ----------------------------');
exception 

    when others then
    
    -- check for open cursor
    if sys.dbms_sys_sql.is_open(v_cursor) then
        sys.dbms_sys_sql.close_cursor(v_cursor);
    end if;
    
    dbms_output.put_line('-- Error: ----------------------------');
    dbms_output.put_line('-- Error: Message :: '||SQLERRM );      
    dbms_output.put_line('-- Error: ----------------------------');
    
	-- log this error also to the alert log
    sys.dbms_system.ksdwrt ( sys.dbms_system.alert_file, '-- Error: kill Session with sys.kill_other_session fails with ::'||SQLERRM);

    raise;

end kill_other_session;


