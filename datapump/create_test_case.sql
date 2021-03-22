-- Source DB 

create user GPIDBA identified by "xxxxxxxxxxxxxxxxx";
grant connect, resource to GPIDBA

grant DATAPUMP_EXP_FULL_DATABASE  to GPIDBA


---




-- Target/Destination 

create user GPIDBA identified by "xxxxxxxxxxxxxxxxx";
grant connect, resource to GPIDBA;

grant DATAPUMP_IMP_FULL_DATABASE  to GPIDBA;


CREATE directory BACKUP AS "/opt/oracle/acfs/import";

GRANT READ,WRITE ON directory BACKUP TO GPIDBA;

connect GPIDBA/"xxxxxxxxxxxxxxxxx"

CREATE DATABASE LINK DP_TRANSFER CONNECT TO GPIDBA IDENTIFIED BY "xxxxxxxxxxxxxxxxx" USING 'TMGTSTDB';


SQL> select global_name from global_name@DP_TRANSFER;





