--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the object count of none default users
-- Date:   October 2013
     
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 

variable PUSERNAME varchar2(32)

prompt
prompt Parameter 1 = User  Name          => &&USER_NAME.
prompt

begin
 if length('&&USER_NAME.') < 1 then
   :PUSERNAME:='%';
 else
   :PUSERNAME:='&&USER_NAME.'||'%';
 end if;
end;
/

column OWNER format a25  

--user summary
--break on owner SKIP 1
--COMPUTE SUM OF size_GB ON owner

ttitle "MegaByte DB Objects total" SKIP 2

column DUMMY NOPRINT;
COMPUTE SUM OF size_GB ON DUMMY;
BREAK ON DUMMY;

column username format a22
column OBJ_TYPE format a22
column size_GB format 9G999G999G990D999

select  null dummy
     , u.username
     , o.obj_type
	 , o.obj_count 
	 , sum(o.size_GB) as size_GB
 from (
  select count(*) as obj_count, s.segment_type as obj_type, o.owner  ,round( sum(s.bytes) /1024/1024/1024 , 3) as size_GB
	  from dba_objects o, dba_segments s
	 where s.owner=o.owner
	   and s.segment_name=o.object_name
	   and nvl(s.partition_name,'n/a')=nvl(o.subobject_name,'n/a')
	 group by s.segment_type,o.owner
	union
	select count(*) as obj_count, s.segment_type as obj_type, l.owner  ,round( sum(s.bytes) /1024/1024/1024 , 3) as size_GB
	from dba_lobs l
	   , dba_segments s
	where l.segment_name  = s.segment_name(+)
	  and l.owner=s.owner
	  group by s.segment_type,l.owner ) o
 , dba_users u
where o.owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','PUBLIC','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT','PUBLIC','TSMSYS')
  and o.obj_type in ('TABLE','INDEX','LOB','TABLE PARTITION','INDEX PARTITION','MATERIALIZED VIEW','LOBSEGMENT','LOBINDEX')
  --and o.obj_type in ('INDEX','INDEX PARTITION')
   and u.username = o.owner (+)
  and u.username like upper(:PUSERNAME)
group by u.username,o.obj_type,o.obj_count
--GROUP BY rollup (owner,obj_type,obj_count)
order by u.username,o.obj_type
/

ttitle "MegaByte DB Objects in Trash" SKIP 2

select null dummy
     , owner
	 , round( sum(s.bytes) /1024/1024/1024 , 3) as size_GB 
  from dba_segments s 
 where owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','PUBLIC','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT','PUBLIC','TSMSYS')
   and segment_name like 'BIN%'
   and owner like upper(:PUSERNAME)
 group by owner
/


ttitle "MegaByte DB Objects declared as Temporary" SKIP 2

select null dummy
    , owner
    , round( sum(s.bytes) /1024/1024/1024 , 3) as size_GB 
 from dba_segments s 
where owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','PUBLIC','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT','PUBLIC','TSMSYS')
  and segment_type = 'TEMPORARY'
  and owner like upper(:PUSERNAME)
group by owner
/

ttitle off

clear BREAK

--undef variables ---

undefine PUSERNAME 

---------------------
set verify on