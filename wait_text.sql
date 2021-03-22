--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: text to a wait event - parameter 1 part of the event name
--==============================================================================
-- http://alexzeng.wordpress.com/2013/07/16/enqueue-waits-in-oracle-database-10g/
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define WAITNAME='&1'

prompt
prompt Parameter 1 = WAITNAME    => &&WAITNAME.
prompt

column KSQSTRSN   format a30
column KSQSTEXPL  format a50

select KSQSTTYP
     , KSQSTRSN     
     , KSQSTEXPL 
 from  X$KSQST
where  upper(KSQSTRSN) like upper('%'||'&&WAITNAME'||'%')
/ 

