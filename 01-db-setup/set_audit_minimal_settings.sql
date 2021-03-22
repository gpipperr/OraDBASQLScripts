-- 
audit connect;
audit create session by access;
audit create session whenever not successful;

---
audit alter any table by access;
audit create any table by access;
audit drop any table by access;
audit create any procedure by access;
audit drop any procedure by access;
audit alter any procedure by access;
audit grant any privilege by access;
audit grant any object privilege by access;
audit grant any role by access;
audit audit system by access;
audit create external job by access;
audit create any job by access;
audit create any library by access;
audit create public database link by access;
audit exempt access policy by access;
audit alter user by access;
audit create user by access;
audit role by access;
audit drop user by access;
audit alter database by access;
audit alter system by access;
audit alter profile by access;
audit drop profile by access;
audit database link by access;
audit system audit by access;
audit profile by access;
audit public synonym by access;
audit system grant by access;

 
-- Audit failed commands and connects
-- will audit all the commands listed for alter system, cluster, database link, procedure, rollback segment, sequence, synonym, table, tablespace, type, and view
audit resource whenever not successful;

--
audit insert, update, delete on sys.aud$ by access;
