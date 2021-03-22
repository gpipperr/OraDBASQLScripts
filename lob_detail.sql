--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc - Get the details for the lob data type for this table 
--          Parameter owner and table name
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define OWNER         = '&1' 
define TABLE_NAME    = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Table Name  => &&TABLE_NAME.
prompt


column owner        format a12 heading "User"
column table_name   format a30 heading "Table name"
column column_name  format a20 heading "Column|Name"
column segment_name format a30 heading "Segment|Name"
column IN_ROW       format a3 heading "In|Row"
column SECUREFILE   format a3 heading "Sec|File"

--
-- to avoid ORA-00600: internal error code, arguments: [qmxtrGetRealOPn], [], [], [], [], [], [], [], [], [], [], []
-- use this hint! /*+ NO_XML_QUERY_REWRITE */
--

select /*+ NO_XML_QUERY_REWRITE */ * 
   from xmltable('ROWSET/ROW/*' 
			passing xmltype(
							cursor(
								select * from dba_lobs where upper(owner)=upper('&&OWNER.') and upper(table_name)=upper('&&TABLE_NAME.')
							)
						) 
			columns property varchar2(30) path 'node-name(.)'
					, value      varchar2(30) path '.'
		 )
/

set serveroutput on

declare

	cursor c_lob_info is 
		select segment_name
		     , owner
			  , securefile		
			  , decode(securefile,'YES','SECUREFILE','BASICFILE') as lob_type
			from dba_lobs
     where upper(owner)=upper('&&OWNER.') 
	   and upper(table_name)=upper('&&TABLE_NAME.');
		
		v_segment_size_blocks   number;
		v_segment_size_bytes    number;
		v_used_blocks           number;
		v_used_bytes            number;
		v_expired_blocks        number;
		v_expired_bytes         number;
		v_unexpired_blocks      number;
		v_unexpired_bytes       number;
		v_unf   						number;
		v_unfb  						number;
		v_fs1   						number;
		v_fs1b  						number;
		v_fs2   						number;
		v_fs2b  						number;
		v_fs3   						number;
		v_fs3b  						number;
		v_fs4   						number;
		v_fs4b  						number;
		v_full  						number;
		v_fullb 						number;
		
		v_file_name dba_data_files.file_name%type;
		v_tablespace_name dba_segments.TABLESPACE_NAME%type;
		v_segment_management dba_tablespaces.SEGMENT_SPACE_MANAGEMENT%type;
begin
  for rec in c_lob_info
  loop
		  
		
		dbms_output.put_line('Info -- Segment Name              :' || rec.segment_name);
		dbms_output.put_line('Info -- LOB File Type             :' || rec.lob_type);
				
		--to fix 
		-- declare
		--*
		--ERROR at line 1:
		--ORA-03213: Invalid Lob Segment Name for DBMS_SPACE package
		--ORA-06512: at "SYS.DBMS_SPACE", line 210
		--ORA-06512: at line 12
		-- use right package for each Lob type!
		begin
		
			if rec.securefile ='YES' then
			  dbms_space.space_usage(
					segment_owner           => rec.owner,
					segment_name            => rec.segment_name,
					segment_type            => 'LOB',
					partition_name          => NULL,
					segment_size_blocks     => v_segment_size_blocks,
					segment_size_bytes      => v_segment_size_bytes,
					used_blocks             => v_used_blocks,
					used_bytes              => v_used_bytes,
					expired_blocks          => v_expired_blocks,
					expired_bytes           => v_expired_bytes,
					unexpired_blocks        => v_unexpired_blocks,
					unexpired_bytes         => v_unexpired_bytes);
				

				dbms_output.put_line('Info -- Secure File in use');
				dbms_output.put_line('Info -- segment_size_blocks       :'||  v_segment_size_blocks);
				dbms_output.put_line('Info -- segment_size_bytes in MB  :'||  to_char(v_segment_size_bytes/(1024*1024),'999G999G999D99'));
				dbms_output.put_line('Info -- used_bytes  in MB         :'||  to_char(v_used_bytes/(1024*1024),'999G999G999D99'));
				dbms_output.put_line('Info -- expired_bytes  in MB      :'||  to_char(v_expired_bytes/(1024*1024),'999G999G999D99'));
				dbms_output.put_line('Info -- unexpired_bytes in MB     :'||  to_char(v_unexpired_bytes/(1024*1024),'999G999G999D99'));
					
			else
				dbms_space.space_usage(
					 segment_owner            => rec.owner
					,segment_name             => rec.segment_name
					,segment_type             => 'LOB'
					,unformatted_blocks       => v_unf
					,unformatted_bytes        => v_unfb
					,fs1_blocks               => v_fs1
					,fs1_bytes                => v_fs1b
					,fs2_blocks               => v_fs2
					,fs2_bytes                => v_fs2b
					,fs3_blocks               => v_fs3
					,fs3_bytes                => v_fs3b
					,fs4_blocks               => v_fs4
					,fs4_bytes                => v_fs4b
					,full_blocks              => v_full
					,full_bytes               => v_fullb
					,partition_name           => '');
			
					dbms_output.put_line('Info -- Basic File in use');
					dbms_output.put_line('Info -- Total Count of blocks that are unformatted              :'||to_char(v_unf,'999G999G999') ||' |Bytes MB:'||to_char(v_unfb/(1024*1024),'999G999G999D99'));
					dbms_output.put_line('Info -- Total Count of blocks that are full in the segment      :'||to_char(v_full,'999G999G999')||' |Bytes MB:'||to_char(v_fullb/(1024*1024),'999G999G999D99'));
				  
					dbms_output.put_line('Info -- ');
				  
				  dbms_output.put_line('Info -- Count of blocks that has at least 0  to 25%  free space :'||v_fs1||' |Bytes :'||v_fs1b);
				  dbms_output.put_line('Info -- Count of blocks that has at least 25 to 50%  free space :'||v_fs2||' |Bytes :'||v_fs2b);
				  dbms_output.put_line('Info -- Count of blocks that has at least 50 to 75%  free space :'||v_fs3||' |Bytes :'||v_fs3b);
				  dbms_output.put_line('Info -- Count of blocks that has at least 75 to 100% free space :'||v_fs4||' |Bytes :'||v_fs4b);
				  
				  dbms_output.put_line('Info ------------------------------------------------------------------');
			
			end if;	
		
		 exception
		  when others then
				dbms_output.put_line('Error --');
				dbms_output.put_line('Error -- '||SQLERRM);
				dbms_output.put_line('Error --   +This procedure can be used only on segments in  tablespaces with AUTO SEGMENT SPACE MANAGEMENT');
				dbms_output.put_line('Error --   +Action:  Check the segment name and type and reissue the statement');
				select distinct  s.TABLESPACE_NAME , t.SEGMENT_SPACE_MANAGEMENT into v_tablespace_name , v_segment_management
				 from dba_segments s , dba_tablespaces t
				where upper(s.segment_name) like upper('&&TABLE_NAME.')   
				  and upper(s.owner)=upper('&&OWNER.')
				  and s.TABLESPACE_NAME=t.TABLESPACE_NAME;
				  
				dbms_output.put_line('Error --   +Tablespace for the table &&TABLE_NAME.:: '||v_tablespace_name ||' - Segment Management for this tablespace:: '||v_segment_management);
				dbms_output.put_line('Error --');
		 end;
	end loop;
	
end;
/

