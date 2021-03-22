-- ======================================
-- GPI - Gunther Pippèrr
-- Database Resident Connection Pooling (DRCP)
-- =======================================
-- Master Note: Overview of Database Resident Connection Pooling (DRCP) (Doc ID 1501987.1)
-- =======================================
set linesize 130 pagesize 300 

column CONNECTION_POOL                format a30      heading "CONNECTION|POOL"        
column STATUS                         format a10      heading "STATUS"                 
column MINSIZE                        format 99       heading "MINSIZE"                
column MAXSIZE                        format 999      heading "MAXSIZE"                
column INCRSIZE                       format 99       heading "INCRSIZE"               
column SESSION_CACHED_CURSORS         format 999      heading "SESSION|CACHED_CURSORS" 
column INACTIVITY_TIMEOUT             format 999      heading "INACTIVITY|TIMEOUT"     
column MAX_THINK_TIME                 format 999      heading "MAX_THINK_TIME"         
column MAX_USE_SESSION                format 999999   heading "MAX_USE|SESSION"        
column MAX_LIFETIME_SESSION           format 999999   heading "MAX_LIFETIME|SESSION"
column NUM_CBROK                      format 99       heading "NUM|CBROK"              
column MAXCONN_CBROK                  format 999999   heading "MAXCONN|CBROK"          

ttitle "Settings of the connection pool" skip 2

select CONNECTION_POOL       
		, STATUS                
		, MINSIZE               
		, MAXSIZE               
		, INCRSIZE              
		, SESSION_CACHED_CURSORS
		, INACTIVITY_TIMEOUT    
		, MAX_THINK_TIME        
		, MAX_USE_SESSION       
		, MAX_LIFETIME_SESSION  
		, NUM_CBROK             
		, MAXCONN_CBROK         
from DBA_CPOOL_INFO
order by 1
/

-----------------------------------------------------------


column POOL_NAME                     format  a30  heading "POOL|NAME"              
column NUM_OPEN_SERVERS              format  9999 heading "NUM_OPEN|SERVERS"       
column NUM_BUSY_SERVERS              format  9999 heading "NUM_BUSY|SERVERS"       
column NUM_AUTH_SERVERS              format  9999 heading "NUM_AUTH|SERVERS"       
column NUM_REQUESTS                  format  9999 heading "NUM|REQUESTS"           
column NUM_HITS                      format  9999 heading "NUM|HITS"               
column NUM_MISSES                    format  9999 heading "NUM|MISSES"             
column NUM_WAITS                     format  9999 heading "NUM|WAITS"              
column WAIT_TIME                     format  9999 heading "WAIT|TIME"              
column CLIENT_REQ_TIMEOUTS           format  9999 heading "CLIENT_REQ|TIMEOUTS"    
column NUM_AUTHENTICATIONS           format  9999 heading "NUM|AUTHENTICATIONS"    
column NUM_PURGED                    format  9999 heading "NUM|PURGED"             
column HISTORIC_MAX                  format  9999 heading "HISTORIC|MAX"          

ttitle "Statistics of the connection pool usage" skip 2

select POOL_NAME
		,NUM_OPEN_SERVERS
		,NUM_BUSY_SERVERS
		,NUM_AUTH_SERVERS
		,NUM_REQUESTS
		,NUM_HITS
		,NUM_MISSES
		,NUM_WAITS
		,WAIT_TIME
		,CLIENT_REQ_TIMEOUTS
		,NUM_AUTHENTICATIONS
		,NUM_PURGED
		,HISTORIC_MAX
from V$CPOOL_STATS 
 order by 1
/ 


ttitle "Statistics  about the connection class level statistics for the pool per instance" skip 2

column CCLASS_NAME            format a20   heading "CCLASS|NAME"        
column NUM_REQUESTS           format  999  heading "NUM|REQUESTS"       
column NUM_HITS               format  999  heading "NUM|HITS"           
column NUM_MISSES             format  999  heading "NUM|MISSES"         
column NUM_WAITS              format  999  heading "NUM|WAITS"          
column WAIT_TIME              format  999  heading "WAIT|TIME"          
column CLIENT_REQ_TIMEOUTS    format  999  heading "CLIENT|REQ_TIMEOUTS"
column NUM_AUTHENTICATIONS    format  999  heading "NUM|AUTHENTICATIONS"


select CCLASS_NAME
	, NUM_REQUESTS
	, NUM_HITS
	, NUM_MISSES
	, NUM_WAITS
	, WAIT_TIME
	, CLIENT_REQ_TIMEOUTS
	, NUM_AUTHENTICATIONS
from  V$CPOOL_CC_STATS
/

ttitle "Session using DRCP" skip 2
 
column USERNAME          format a20     heading "USERNAME"
column PROXY_USER        format a10     heading "PROXY|USER"
column CCLASS_NAME       format a15     heading "CCLASS|NAME"
column PURITY            format a10     heading "PURITY"     
column TAG               format a10     heading "TAG"          
column SERVICE           format a10     heading "SERVICE"
column PROGRAM           format a15     heading "PROGRAM"         
column MACHINE           format a15     heading "MACHINE"         
column TERMINAL          format a15     heading "TERMINAL"         
column CONNECTION_MODE   format a10     heading "CONN|MODE"
column CONNECTION_STATUS format a10     heading "CONN|STATUS"
column CLIENT_REGID      format 9999    heading "CLIENT|REGID"

select USERNAME
	, PROXY_USER
	, CCLASS_NAME
	, PURITY
	--, TAG
	, SERVICE
	, PROGRAM
	--, MACHINE
	, TERMINAL
	, CONNECTION_MODE
	, CONNECTION_STATUS
	, CLIENT_REGID
from V$CPOOL_CONN_INFO
order by 1
/


ttitle off

