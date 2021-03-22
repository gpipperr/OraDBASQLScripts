--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get informations about mat views
--==============================================================================
-- http://docs.oracle.com/cd/B19306_01/server.102/b14237/statviews_1105.htm
--==============================================================================

set linesize 130 pagesize 300 

column owner             format a10 heading  "Owner"
column mview_name        format a30 heading "Mview|Name"
column last_refresh_date format a16 heading "Last|refresh"
column refresh_method    format a8  heading "Ref|mod"
column staleness         format a10 heading "Stale"
column rewrite_enabled   format a3  heading "RW|ena"
column comments          format a20  heading "Comments"     word_wrapped
column detailobj_name    format a20 heading "Base|Tables"
column size_mb           format 999G999G999 heading "Size"

break on owner skip 2
compute sum of SIZE_MB on owner;

  select ma.owner
       ,  ma.mview_name
       ,  round (sum (  ms.bytes / 1024 / 1024),  2) as size_mb
       ,  to_char (ma.last_refresh_date, 'dd.mm.RR HH24:mi') as last_refresh_date
       ,  ma.refresh_method
       ,  ma.staleness
       ,  ma.rewrite_enabled
       --, md.detailobj_name
       ,  nvl (mc.comments, '-') as comments
    from dba_mviews ma, dba_mview_comments mc--, dba_mview_detail_relations md
         , dba_segments ms
   where     ma.owner = mc.owner(+)
         and ma.mview_name = mc.mview_name(+)
         -- and ma.owner      = md.owner (+)
         -- and ma.mview_name = md.mview_name (+)
         and ma.owner = ms.owner(+)
         and ma.mview_name = ms.segment_name(+)
group by ma.owner
       ,  ma.mview_name
       ,  to_char (ma.last_refresh_date, 'dd.mm.RR HH24:mi')
       ,  ma.refresh_method
       ,  ma.staleness
       ,  ma.rewrite_enabled
       --, md.detailobj_name
       ,  nvl (mc.comments, '-')
order by ma.owner, ma.mview_name
/

prompt
prompt ... Stale Status
prompt ... FRESH     - Materialized view is a read-consistent view of the current state of its masters
prompt ... STALE     - Materialized view is out of date because one or more of its masters has changed.
prompt ...             If the materialized view was FRESH before it became STALE,
prompt ...             then it is a read-consistent view of a former state of its masters.
prompt ... UNUSABLE  - Materialized view is not a read-consistent view of its masters from any point in time
prompt ... UNKNOWN   - Oracle Database does not know whether the materialized view is in a read-consistent view
prompt ...             of its masters from any point in time
prompt ...             this is the case for materialized views created on prebuilt tables)
prompt ... UNDEFINED - Materialized view has remote masters. The concept of staleness is not defined for such materialized views.
prompt

clear break