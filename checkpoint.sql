--==============================================================================
-- GPI - Gunther Pippèrr
--==============================================================================
set linesize 130 pagesize 300 

@select v$instance_recovery;


prompt RECOVERY_ESTIMATED_IOS         => geschaetzte Anzahl von Bloecken fuer das aktuelle Recovery beim Einsatz des FAST_START_IO_TARGET Parameters
prompt ACTUAL_REDO_BLKS               => Anzahl von Bloecken fuer das Recovery
prompt TARGET_REDO_BLKS               => Ziel fuer die minimale Anzahl, der zu lesenden Bloecke beim Recovery (Minium der unteren Spalten) (Checkpoint Ausloeser!)
prompt LOG_FILE_SIZE_REDO_BLKS        => Maximale Anzahl Redos, die sicherstellen, das ein Log Switch nicht stattfindet bevor ein Checkpoint komplett erfolgt ist
prompt LOG_CHKPT_TIMEOUT_REDO_BLKS    => Anzahl der Bloecke um den Parameter LOG_CHECKPOINT_TIMEOUT zu erfuellen
prompt LOG_CHKPT_INTERVAL_REDO_BLKS   => Anzahl der Bloecke um den Parameter LOG_CHECKPOINT_INTERVALL zu erfuellen
prompt FAST_START_IO_TARGET_REDO_BLKS => Anzahl der Bloecke um den Parameter FAST_START_IO_TARGET zu erfuellen

