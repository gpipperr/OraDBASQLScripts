--==============================================================================
-- GPI - Gunther Pippèrr
--
--==============================================================================
-- http://www.idevelopment.info/data/Oracle/DBA_tips/Advanced_Queuing/AQ_2.shtml#Dequeue Message
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

SET SERVEROUTPUT ON

DECLARE

    dequeue_options      dbms_aq.dequeue_options_t;
    message_properties   dbms_aq.message_properties_t;
    message_handle       RAW(16);
    message              aq.message_type;

BEGIN

    -- -------------------------------------------------------

    dequeue_options.CONSUMER_NAME           := NULL;
    dequeue_options.DEQUEUE_MODE            := DBMS_AQ.REMOVE;
    dequeue_options.NAVIGATION              := DBMS_AQ.NEXT_MESSAGE;
    dequeue_options.VISIBILITY              := DBMS_AQ.IMMEDIATE;
    dequeue_options.WAIT                    := DBMS_AQ.FOREVER;
    dequeue_options.MSGID                   := 'xxxxxxxxxxxxxxxxxxxxxxx';
    dequeue_options.CORRELATION             := 'TEST MESSAGE';

    -- -------------------------------------------------------

    DBMS_AQ.DEQUEUE (
        queue_name         => 'SYS.ALERT_QUE'
      , dequeue_options    => dequeue_options
      , message_properties => message_properties
      , payload            => message
      , msgid              => message_handle
    );

    -- -------------------------------------------------------

    dbms_output.put_line('+-----------------+');
    dbms_output.put_line('| MESSAGE PAYLOAD |');
    dbms_output.put_line('+-----------------+');
    dbms_output.put_line('- Message ID   := ' || message.message_id);
    dbms_output.put_line('- Subject      := ' || message.subject);
    dbms_output.put_line('- Message      := ' || message.text);
    dbms_output.put_line('- Dollar Value := ' || message.dollar_value);

    -- -------------------------------------------------------

    COMMIT;

    -- -------------------------------------------------------

END;
/