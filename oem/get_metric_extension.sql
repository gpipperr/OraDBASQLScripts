--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get all user defined metric extension
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off


define METRIK_NAME  = '&1'

prompt
prompt Parameter 1 =  METRIK_NAME => &&METRIK_NAME.
prompt


column target_type format a10
column name format a30
column display_name format a30
column extype format a10

  select mg.target_type
       ,  decode (mg.me_type, 1, 'Metrik Ext', 'Config Ext') as extype
       ,  mg.name
       ,  mg.latest_prod_version
    from em_mext_groups mg
   where mg.name = '&&METRIK_NAME.'
order by mg.me_type
/

  select m.name
       ,  m.version
       ,  m.target_type
       ,  m.display_name
       ,  m.DESCRIPTION
    from em_mext_versions m
   where     m.version = (select max (i.version)
                            from em_mext_versions i
                           where i.name = m.name)
         and m.name = '&&METRIK_NAME.'
order by m.target_type
/
 
 