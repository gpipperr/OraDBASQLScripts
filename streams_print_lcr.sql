--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get one LCR of a streams replication 
--==============================================================================
set verify off
set linesize 130 pagesize 3000 

prompt.... Detail Error messages around the actual error

select  em.local_transaction_id
      , em.object_owner || '.' || em.object_name as object_name
      , em.operation
	  , em.transaction_message_number
	  , em.message
 from dba_apply_error_messages  em
    , dba_apply_error ar
where em.local_transaction_id=ar.local_transaction_id
  and em.transaction_message_number = &LCR_NUM.
order by  em.local_transaction_id
        , em.transaction_message_number
		, em.position
/



