--==============================================================================
-- GPI - Gunther Pippèrr
--
--==============================================================================
set linesize 130 pagesize 300 
set verify off


ttitle left  "Process List of the Oracle BG Processes" skip 2


/*
-- https://docs.oracle.com/cd/E18283_01/server.112/e17110/bgprocesses.htm#BBBDIIHC
ABMR	Auto BMR Background Process
ACFS	ASM Cluster File System CSS Process
ACMS	Atomic Control File to Memory Service Process
APnn	Logical Standby / Streams Apply Process Coordinator Process
ARBn	ASM Rebalance Process
ARCn	Archiver Process
ASMB	ASM Background Process
ASnn	Logical Standby / Streams Apply Process Reader Server or Apply Server
BMRn	Automatic Block Media Recovery Slave Pool Process
Bnnn	ASM Blocking Slave Process for GMON
CJQ0	Job Queue Coordinator Process
CKPT	Checkpoint Process
CPnn	Streams Capture Process
CSnn	Streams Propagation Sender Process
CSnn	I/O Calibration Process
CTWR	Change Tracking Writer Process
DBRM	Database Resource Manager Process
DBWn	Database Writer Process
DIA0	Diagnostic Process
DIAG	Diagnostic Capture Process
DMnn	Data Pump Master Process
DMON	Data Guard Broker Monitor Process
Dnnn	Dispatcher Process
DRnn	ASM Disk Resynchronization Slave Process
DSKM	Slave Diskmon Process
DWnn	Data Pump Worker Process
EMNC	EMON Coordinator Process
Ennn	EMON Slave Process
FBDA	Flashback Data Archiver Process
FMON	File Mapping Monitor Process
FSFP	Data Guard Broker Fast Start Failover Pinger Process
GCRnFoot 1 	Global Conflict Resolution Slave Process
GEN0	General Task Execution Process
GMON	ASM Disk Group Monitor Process
GTXn	Global Transaction Process
Innn	Disk and Tape I/O Slave Process
INSV	Data Guard Broker Instance Slave Process
Jnnn	Job Queue Slave Process
LCK0	Instance Enqueue Background Process
LGWR	Log Writer Process
LMD0	Global Enqueue Service Daemon 0 Process
LMHB	Global Cache/Enqueue Service Heartbeat Monitor
LMON	Global Enqueue Service Monitor Process
LMSn	Global Cache Service Process
LSP0	Logical Standby Coordinator Process
LSP1	Logical Standby Dictionary Build Process
LSP2	Logical Standby Set Guard Process
Lnnn	Pooled Server Process
MARK	Mark AU for Resynchronization Coordinator Process
MMAN	Memory Manager Process
MMNL	Manageability Monitor Lite Process
MMON	Manageability Monitor Process
Mnnn	MMON Slave Process
MRP0	Managed Standby Recovery Process
MSnn	LogMiner Worker Process
Nnnn	Connection Broker Process
NSAn	Redo Transport NSA1 Process
NSSn	Redo Transport NSS1 Process
NSVn	Data Guard Broker NetSlave Process
OCFn	ASM CF Connection Pool Process
Onnn	ASM Connection Pool Process
PING	Interconnect Latency Measurement Process
PMON	Process Monitor
Pnnn	Parallel Query Slave Process
PRnn	Parallel Recovery Process
PSP0	Process Spawner Process
QMNC	AQ Coordinator Process
Qnnn	AQ Server Class Process
RBAL	ASM Rebalance Master Process
RCBG	Result Cache Background Process
RECO	Recoverer Process
RMSn	Oracle RAC Management Process
Rnnn	ASM Block Remap Slave Process
RPnn	Capture Processing Worker Process
RSM0	Data Guard Broker Worker Process
RSMN	Remote Slave Monitor Process
RVWR	Recovery Writer Process
SMCO	Space Management Coordinator Process
SMON	System Monitor Process
Snnn	Shared Server Process
TEMn	ASM disk Test Error Emulation Process
VBGn	Volume Background Process
VDBG	Volume Driver Process
VKRM	Virtual Scheduler for Resource Manager Process
VKTM	Virtual Keeper of Time Process
VMB0	Volume Membership Process
Vnnn	ASM Volume I/O Slave Process
Wnnn	Space Management Slave Process
XDMG	Exadata Automation Manager
XDWK	Exadata Automation Manager
Xnnn	ASM Disk Expel Slave Process
*/


column process_id format a8     heading "Process|ID"
column inst_id    format 99     heading "IN|ID"
column username   format a8     heading "DB User|name"
column osusername   format a8   heading "OS User|name"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a14    heading "Server|Name"
column terminal   format a14    heading "Remote|terminal"
column program    format a28    heading "BG|Program"
column module     format a15    heading "Remote|module"
column client_info format a15   heading "Client|info"
column pname       format a8    heading "Process|name"
column tracefile   format a20   heading "Trace|File"
column error       format 999999  heading "Error|Number"
column DESCRIPTION format a35  heading "Description"  word_wrapped


  select p.inst_id
       ,  to_char (p.spid) as process_id
       ,  vs.sid
       ,  vs.serial#
       ,  p.username as osusername
       ,  pb.name
       ,  pb.DESCRIPTION
       ,  pb.error
       ,  vs.machine
       ,  nvl (vs.module, ' - ') as module
       ,  vs.program
    --, substr(p.tracefile,length(p.tracefile)-REGEXP_INSTR(reverse(p.tracefile),'[\/|\]')+2,1000) as tracefile
    --, p.tracefile
    from gv$session vs, gv$process p, gv$bgprocess pb
   where     vs.paddr = p.addr
         and vs.inst_id = p.inst_id
         and pb.PADDR = p.addr
         and pb.INST_ID = p.inst_id
         and vs.username is null
order by pb.name, p.inst_id
/

ttitle left  "Trace File Locations" skip 2

column full_trace_file_loc  format a100  heading "Trace|File"

  select p.inst_id
       ,  pb.name
       ,  to_char (p.spid) as process_id
       ,  p.tracefile as full_trace_file_loc
    from gv$session vs, gv$process p, gv$bgprocess pb
   where     vs.paddr = p.addr
         and vs.inst_id = p.inst_id
         and pb.PADDR = p.addr
         and pb.INST_ID = p.inst_id
         and vs.username is null
order by pb.name, p.inst_id
/

ttitle off