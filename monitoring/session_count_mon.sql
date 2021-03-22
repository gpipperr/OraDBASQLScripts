select 
  sum(decode(s.type,'BACKGROUND',1,0)) BackgroundSessions
, sum(case when s.type='USER' then decode(status,'ACTIVE',0,1) else 0 end)  UserSessions
, sum(case when s.type='USER' then decode(status,'ACTIVE',1,0) else 0 end) ActiveSessions 
, count(*) as TotalProcessCount
 from v$session s ,
      v$process p 
where  s.PADDR (+) = p.ADDR 
and nvl(s.sid,-1) <> sys_context('userenv','SID') ;
