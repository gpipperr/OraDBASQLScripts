-- ============================
-- Create a default user for plsql development
-- ============================

create user &&USERNAME.
identified by &&USERNAME.2013
   default tablespace USERS
 temporary tablespace TEMP
   profile DEFAULT
/   

-- Grant/Revoke system privileges 
grant unlimited tablespace to &&USERNAME.


-- Roles
--
grant connect to  &&USERNAME.
grant resource to &&USERNAME.


-- direct grants for pl/sql
--
grant create view to &&USERNAME.
grant create table to &&USERNAME.
grant create sequence to &&USERNAME.

-- Object grant in the database
--