


define DBID=1517503088
prompt check if you have set the correct DB ID = &DBID !

variable jobno number

set verify on

begin
 dbms_job.submit(job => :jobno
  , what => 'statspack.purge(i_num_days=>14,i_extended_purge=>true,I_DBID=>&&DBID, I_INSTANCE_NUMBER=> 1 ); '
  , next_date => sysdate
  , interval  => 'trunc(SYSDATE+1)+(((1/24)*4)+((1/(26*60))*5))'
  , no_parse  => false
  , instance  => 1
  , force     => true);
 
end;
/


commit

begin
  dbms_job.submit(
	job       => :jobno
  , what      => 'statspack.purge(i_num_days=>14,i_extended_purge=>true,I_DBID=>&&DBID, I_INSTANCE_NUMBER=> 2 ); '
  , next_date =>  sysdate
  , interval  => 'trunc(SYSDATE+1)+(((1/24)*4)+((1/(26*60))*12))'
  , no_parse  => true
  , instance  => 2
  , force     => true);

end;
/

  
commit;


set verify off


@jobs_dbms

