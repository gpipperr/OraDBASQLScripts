--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   SQL Script to check the size of a table
-- Doku:   http://www.pipperr.de/dokuwiki/doku.php?id=dba:sql_groesse_tabelle
-- Date:   08.2013
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define lnum  = "format 9G999G999D99"
define num   = "format 99G999"
define snum  = "format 9G999"


define ENTER_OWNER='&1'
define ENTER_TABLE='&2'


prompt
prompt Parameter 1 = User Name     => &&ENTER_OWNER.
prompt Parameter 2 = Table Name    => &&ENTER_TABLE.
prompt


ttitle left  "Check if the table is a IOT Table" skip 2
column COMPRESSION FOLD_BEFORE

select 'This table is '||decode(nvl(IOT_TYPE,'-'),'IOT','Index-organized','Heap-organized') as TABLE_TYPE
     , 'This table compression is '||  COMPRESSION  || decode(COMPRESSION,'DISABLED','!',' Type is '||COMPRESS_FOR) as COMPRESSION
  from  dba_tables 
 where upper(table_name) like upper('&ENTER_TABLE.')
    and upper(owner) = upper('&ENTER_OWNER.')
/	


ttitle left  "Space Usage of the table &ENTER_OWNER..&ENTER_TABLE." skip 2


column segment_name format A20
column owner        format A10
column Size_MB 		&&lnum
column count_blk 	format 999G999G999
column count_ext 	&&lnum
column count_part 	&&snum
column tablespace_name format a20 heading "Tablespace Name"

select segment_name
      ,owner
      ,round(sum(bytes) / 1024 / 1024, 3) as Size_MB
      ,sum(blocks) as count_blk
      ,sum(EXTENTS) as count_ext
      ,count(*) as count_part
      ,tablespace_name		
  from dba_segments
 where upper(segment_name) like upper('&ENTER_TABLE.')
   and upper(owner) = upper('&ENTER_OWNER.')
 group by segment_name
         ,owner
			,tablespace_name
/


-- to slow ....
--ttitle left  "Extend Map of this table" skip 2	
--
--declare
--
--  TYPE tt_blocks IS TABLE OF number  INDEX BY BINARY_INTEGER;
--   
--  cursor c_tab_files is
--    select file_id
--          ,TABLESPACE_NAME
--      from DBA_EXTENTS
--     where upper(segment_name) like upper('&ENTER_TABLE.')
--       and upper(owner) = upper('&ENTER_OWNER.')
--     group by file_id
--             ,TABLESPACE_NAME
--     order by file_id;
--
--  cursor c_extend_map(p_file_id DBA_EXTENTS.file_id%type) is
--    select block_id
--          ,blocks
--          ,bytes as Sizeb
--          ,file_id
--      from DBA_EXTENTS
--     where upper(segment_name) like upper('&ENTER_TABLE.')
--       and upper(owner) = upper('&ENTER_OWNER.')
--       and file_id = p_file_id
--     order by file_id
--             ,block_id;
--
--  v_start_block_id DBA_EXTENTS.block_id%type := 0;
--  v_end_block_id   DBA_EXTENTS.block_id%type := 0;
--  v_last_block_id  DBA_EXTENTS.block_id%type := 0;
--
--  v_last_blocks DBA_EXTENTS.blocks%type := 0;
--  v_size        number;
--  p_printout    boolean := true;
--  v_max_blocks  DBA_EXTENTS.block_id%type := 0;
--  v_datafile    dba_data_files.FILE_NAME%type;
--
--  v_block_factor pls_integer;
--  v_block_exists pls_integer;
--  
--  i pls_integer:=1;
--  t_blocks tt_blocks;
--
--begin
--  dbms_output.put_line('Info -- ======= Table Extend Map for table &ENTER_TABLE. - &ENTER_OWNER. =======');
--  for trec in c_tab_files
--  loop
--    dbms_output.put_line('Info -- Analyse file with id :: ' || trec.file_id || ' tablespace :: ' ||
--                         trec.tablespace_name);
--    dbms_output.put_line('Info --');
--    for rec in c_extend_map(p_file_id => trec.file_id)
--    loop
--      if (rec.block_id > (v_last_block_id + v_last_blocks)) then
--      
--        if (v_start_block_id != 0) then
--          dbms_output.put_line('Info -- Start : ' || to_char(v_start_block_id, '999G999G999') || ' -- End  : ' ||
--                               to_char(v_end_block_id + v_last_blocks, '999G999G999') || '  Block -- Size used MB -->' ||
--                               to_char(v_size / 1024 / 1024, '999G990D999'));
--			t_blocks(i):=v_start_block_id;
--			i:=i+1;
--			
--        end if;
--      
--        v_start_block_id := rec.block_id;
--        v_size           := rec.Sizeb;
--      else
--        v_size         := v_size + rec.Sizeb;
--        v_end_block_id := rec.block_id;
--      end if;
--      v_last_block_id := rec.block_id;
--      v_last_blocks   := rec.blocks;
--    end loop;
--    if p_printout then
--      dbms_output.put_line('Info -- Start : ' || to_char(v_start_block_id, '999G999G999') || ' -- End  : ' ||
--                           to_char(v_start_block_id + v_last_blocks, '999G999G999') || '  Block -- Size used MB -->' ||
--                           to_char(v_size / 1024 / 1024, '999G990D999'));
--			t_blocks(i):=v_start_block_id;
--			i:=i+1;
--    end if;
--    select max(block_id) into v_max_blocks from DBA_EXTENTS where file_id = trec.file_id;
--    select FILE_NAME into v_datafile from dba_data_files where FILE_ID = trec.file_id;
--    dbms_output.put_line('Info --');
--    dbms_output.put_line('Info -- last use extend block :: ' || to_char(v_max_blocks) || ' in this datafile :: ' ||
--                         v_datafile);
--    dbms_output.put_line('Info --');
--  end loop;
--
--  for trec in c_tab_files
--  loop
--  
--    select max(block_id) into v_max_blocks from DBA_EXTENTS where file_id = trec.file_id;
--
--  
--    if v_max_blocks > 500000 then
--      v_block_factor := 10000;
--    elsif v_max_blocks > 100000 then
--	  v_block_factor := 10000;
--	else  
--      v_block_factor := 1000;
--    end if;
--	
--	dbms_output.put('Info -- ');
--	dbms_output.put_line('Info -- draw map for :: ' || trec.file_id || ' tablespace :: ' || trec.tablespace_name);
--    dbms_output.put_line('Info -- Each star represent '||v_block_factor||' Blocks');
--    dbms_output.put('Info -- ');
--	
--    for i in 1 .. v_max_blocks
--    loop
--      -- all 1000 Block draw a #
--      if mod(i, v_block_factor) = 0 then
--	  
--        -- check  with the remember values
--		-- faster!
--        --select count(*)
--        --  into v_block_exists
--        --  from DBA_EXTENTS
--        -- where upper(segment_name) like upper('&ENTER_TABLE.')
--        ---   and upper(owner) = upper('&ENTER_OWNER.')
--        --   and file_id = trec.file_id
--        --   and block_id between (i) and i+v_block_factor;
--		
--		 FOR j IN 1 .. t_blocks.COUNT LOOP
--			 if t_blocks(j) between (i) and i+v_block_factor then
--			  v_block_exists:=100;
--			 end if;
--		 END LOOP;  
--		   
--        if v_block_exists > 0 then
--          dbms_output.put('+');
--        else
--          dbms_output.put('#');
--        end if;
--		
--		v_block_exists:=0;		
--      end if;
--      if mod(i, (v_block_factor * 100)) = 0 then
--        dbms_output.put_line('');
--        dbms_output.put('Info -- ');
--      end if;
--    end loop;
--    dbms_output.put_line('');
--    dbms_output.put_line('Info --');
--  end loop;
--
--  dbms_output.put_line('Info -- ======= Finish =======');
--end;
--/


	
/*
Parameter			Description
-----------------------------------------------------------------------
segment_owner		Schema name of the segment to be analyzed
segment_name		Name of the segment to be analyzed
partition_name		Partition name of the segment to be analyzed
segment_type		Type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
unformatted_blocks	Total number of blocks that are unformatted
unformatted bytes	Total number of bytes that are unformatted
fs1_blocks			Number of blocks that has at least 0 to 25% free space
fs1_bytes			Number of bytes that has at least 0 to 25% free space
fs2_blocks			Number of blocks that has at least 25 to 50% free space
fs2_bytes			Number of bytes that has at least 25 to 50% free space
fs3_blocks			Number of blocks that has at least 50 to 75% free space
fs3_bytes			Number of bytes that has at least 50 to 75% free space
fs4_blocks			Number of blocks that has at least 75 to 100% free space
fs4_bytes			Number of bytes that has at least 75 to 100% free space
ful1_blocks			Total number of blocks that are full in the segment
full_bytes			Total number of bytes that are full in the segment


----------------------------

total_blocks				Returns total number of blocks in the segment.
total_bytes					Returns total number of blocks in the segment, in bytes.
unused_blocks				Returns number of blocks which are not used.
unused_bytes				Returns, in bytes, number of blocks which are not used.
last_used_extent_ file_id	Returns the file ID of the last extent which contains data.
last_used_extent_ block_id	Returns the starting block ID of the last extent which contains data.
last_used_block				Returns the last block within this extent which contains data.

*/

set serveroutput on

declare
  unf number;
  unfb number;
  fs1 number;
  fs1b number;
  fs2 number;
  fs2b number;
  fs3 number;
  fs3b number;
  fs4 number;
  fs4b number;
  full number;
  fullb number;
  
  total_blocks number;
  total_bytes number;
  unused_blocks number;
  unused_bytes number;
  lastextf number;
  last_extb number;
  lastusedblock number;

  v_file_name dba_data_files.file_name%type;
  v_tablespace_name dba_segments.TABLESPACE_NAME%type;
  v_segment_management dba_tablespaces.SEGMENT_SPACE_MANAGEMENT%type;
  
  cursor c_seg is
	select  segment_name
	      , owner 
		  , SEGMENT_TYPE
		  , PARTITION_NAME
	  from dba_segments  
	 where upper(segment_name) like upper('&ENTER_TABLE.')  and upper(owner)=upper('&ENTER_OWNER.');
  
begin

	for rec in  c_seg
	loop

		begin 
		  dbms_output.put_line('Info -- Call dbms_space.space_usage for table ( Type:'|| rec.segment_type||' ) ::'||rec.segment_name ||' Partition::'||rec.PARTITION_NAME);
		  
		  dbms_output.put_line('Info ------------------------------------------------------------------');
		  
		  dbms_space.space_usage(
			 segment_owner            => rec.owner
			,segment_name             => rec.segment_name
			,segment_type             => rec.segment_type
			,unformatted_blocks       => unf
			,unformatted_bytes        => unfb
			,fs1_blocks               => fs1
			,fs1_bytes                => fs1b
			,fs2_blocks               => fs2
			,fs2_bytes                => fs2b
			,fs3_blocks               => fs3
			,fs3_bytes                => fs3b
			,fs4_blocks               => fs4
			,fs4_bytes                => fs4b
			,full_blocks              => full
			,full_bytes               => fullb
			,partition_name           => rec.PARTITION_NAME);
		  
		  dbms_output.put_line('Info -- Total Count of blocks that are unformatted              : '||unf ||' |Bytes : '||unfb);
		  dbms_output.put_line('Info -- Total Count of blocks that are full in the segment      : '||full||' |Bytes : '||fullb);
		  
		  dbms_output.put_line('Info -- ');
		  
		  dbms_output.put_line('Info -- Count of blocks that has at least 0  to 25%  free space : '||fs1||' |Bytes : '||fs1b);
		  dbms_output.put_line('Info -- Count of blocks that has at least 25 to 50%  free space : '||fs2||' |Bytes : '||fs2b);
		  dbms_output.put_line('Info -- Count of blocks that has at least 50 to 75%  free space : '||fs3||' |Bytes : '||fs3b);
		  dbms_output.put_line('Info -- Count of blocks that has at least 75 to 100% free space : '||fs4||' |Bytes : '||fs4b);
		  
		  dbms_output.put_line('Info ------------------------------------------------------------------');
		 exception
		  when others then
				dbms_output.put_line('Error --');
				dbms_output.put_line('Error -- '||SQLERRM);
				dbms_output.put_line('Error --   +This procedure can be used only on segments in  tablespaces with AUTO SEGMENT SPACE MANAGEMENT');
				dbms_output.put_line('Error --   +Action:  Check the segment name and type and re-issue the statement');
				select distinct  s.TABLESPACE_NAME , t.SEGMENT_SPACE_MANAGEMENT into v_tablespace_name , v_segment_management
				 from dba_segments s , dba_tablespaces t
				where upper(s.segment_name) like upper('&ENTER_TABLE.')   
				  and upper(s.owner)=upper('&ENTER_OWNER.')
				  and s.TABLESPACE_NAME=t.TABLESPACE_NAME;
				  
				dbms_output.put_line('Error --   +Tablespace for the table &ENTER_TABLE.:: '||v_tablespace_name ||' - Segment Management for this tablespace:: '||v_segment_management);
				dbms_output.put_line('Error --');
		 end;
	 
		 begin 
		  dbms_output.put_line('Info -- Call dbms_space.UNUSED_SPACE for table  ( Type:'|| rec.segment_type||' ) ::'||rec.segment_name);
		  
		  dbms_space.UNUSED_SPACE(rec.owner,rec.segment_name,rec.segment_type, total_blocks,  total_bytes, unused_blocks, unused_bytes, lastextf, last_extb, lastusedblock,rec.PARTITION_NAME); 
		  
		  dbms_output.put_line('Info ------------------------------------------------------------------');
		  dbms_output.put_line('Info -- Used total_blocks                           :'|| total_blocks);
		  dbms_output.put_line('Info -- Used total_bytes                            :'|| total_bytes );
		  dbms_output.put_line('Info -- Unused block                                :'|| unused_blocks );
		  dbms_output.put_line('Info -- Unused byte                                 :'|| unused_bytes );
		  dbms_output.put_line('Info -- File ID of the last extent with data        :'|| lastextf );
		  
		  select file_name into v_file_name from dba_data_files where FILE_ID=lastextf;
		   
		  dbms_output.put_line('Info -- File Name last extent with data             :'|| v_file_name );
		  
		  dbms_output.put_line('Info -- Starting block ID of the last extent        :'|| last_extb );
		  dbms_output.put_line('Info -- Last block within this extent               :'|| lastusedblock );
		  dbms_output.put_line('Info ------------------------------------------------------------------');
		  
		  exception
		  when others then
			 dbms_output.put_line('Error ---'||SQLERRM);
		 end;
	
	end loop;
 
end;
/ 

ttitle off

