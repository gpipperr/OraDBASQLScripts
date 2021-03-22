--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   recreate the statistic of a database
-- Date:   01.2013
-- Doku:   http://www.pipperr.de/dokuwiki/doku.php?id=dba:statistiken
--
-- Src:
-- http://psoug.org/reference/system_stats.html
-- http://docs.oracle.com/cd/E11882_01/server.112/e40402/initparams040.htm#REFRN10023
-- http://docs.oracle.com/cd/E18283_01/server.112/e16638/stats.htm
--==============================================================================


-----------------------------------------------
set timing on
set serveroutput on
set linesize 256
set pagesize 200
set echo on
set serveroutput on

define degree  = "1"
-----------------------------------------------

column last format a14
column owner format a20
column table_name format a30

spool recreate_stat.log



select count (*), owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy') as last
    from dba_tables
group by owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy'), to_char (LAST_ANALYZED, 'YYYYDDMM')
order by owner, to_char (LAST_ANALYZED, 'YYYYDDMM') desc
/


-----------------------------------------------
-- delete all old statistics if necessary
--
--exec DBMS_STATS.DELETE_DATABASE_STATS;
--exec DBMS_STATS.DELETE_DICTIONARY_STATS;
--exec DBMS_STATS.DELETE_FIXED_OBJECTS_STATS;
-----------------------------------------------

-----------------------------------------------
-- gather first system stats over the io of the creation of the system statistic
exec DBMS_STATS.gather_system_stats('Start');

-----------------------------------------------
--
exec  DBMS_STATS.gather_fixed_objects_stats;


-----------------------------------------------
--
exec DBMS_STATS.GATHER_DICTIONARY_STATS (estimate_percent  => 100, degree  => &&degree ,options  => 'GATHER')


-----------------------------------------------
--

declare
   cursor c_owner
   is
        select owner
          from dba_tables
         where owner not in ('SYS', 'SYSTEM', 'XDB')
      --  System User statitiken anlegen?
      -- and  owner not in ('MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','FLOWS_FILES','OLAPSYS','OWBSYS','OWBSYS_AUDIT')
      group by owner;

   v_parallel   number := &&degree;
begin
   dbms_output.put_line (
      '-- Info Start Anlegen der neuen Statisiken für die DB User um ::' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   dbms_output.put_line ('-----------------------');

   for rec in c_owner
   loop
      dbms_output.put_line (
            '-- Info Starte das Anlegen der Statisik für den User ::'
         || rec.owner
         || ' um ::'
         || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));

      if rec.owner not in ('MAIN_USER')
      then
         -- keine histogramme
         dbms_stats.gather_schema_stats (ownname     => rec.owner
                                       ,  options     => 'GATHER'
                                       ,  estimate_percent => dbms_stats.auto_sample_size
                                       ,  cascade     => true
                                       ,  degree      => v_parallel);
      else
         -- Mit Histogrammen
         dbms_stats.gather_schema_stats (ownname     => rec.owner
                                       ,  cascade     => true
                                       ,  estimate_percent => dbms_stats.AUTO_SAMPLE_SIZE
                                       ,  Block_Sample => false
                                       ,  degree      => v_parallel
                                       ,  no_invalidate => true
                                       ,  granularity => 'ALL'
                                       ,  method_opt  => 'FOR ALL COLUMNS SIZE AUTO');
      end if;

      dbms_output.put_line (
            '-- Info Anlegen der Statisik für den User ::'
         || rec.owner
         || ' beendet um ::'
         || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));

      dbms_output.put_line ('-----------------------');
   end loop;

   dbms_output.put_line ('-----------------------');
   dbms_output.put_line (
      '-- Info Anlegen der neuen Statisiken für die DB User um ::' || to_char (sysdate, 'dd.mm.yyyy hh24:mi') || ' beendet');
end;
/

-----------------------------------------
-- Falls etwas fehlt
exec DBMS_STATS.GATHER_DATABASE_STATS (degree=>&&degree,options=>'GATHER AUTO' );

-----------------------------------------
-- end system statistic
execute DBMS_STATS.gather_system_stats('Stop');

------------------------------------------

  select count (*), owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy') as last
    from dba_tables
group by owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy'), to_char (LAST_ANALYZED, 'YYYYDDMM')
order by owner, to_char (LAST_ANALYZED, 'YYYYDDMM') desc
/

spool off;


set echo off
set timing off

