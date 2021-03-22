--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   OEM SQL Script Overview
-- Date:   
--==============================================================================

DOC 
-------------------------------------------------------------------------------
 
#The OEM Query Scripts
--=================

OEM Repository
--==============================================================================

oem/get_target.sql                 - get info for a target

oem/get_target_types.sql  		   - get all deployed target types in the repository
oem/get_target_properties.sql      - get the properties of a target  - parameter 1 the target type 
oem/get_target_info.sql            - get the properties of a target with sample values  - parameter 1 the target type     

oem/get_host_targets.sql           - get all targets on one host
oem/get_upload_status_target.sql   - get the upload status of all targets on a host

oem/get_target_oracle_home.sql     - get the targets to an oracle home target name - parameter 1 - part of the oracle home target name


oem/get_metric_extension.sql       - get all user defined metric extension

oem/get_all_server_push_alerts.sql - get all metrics that are DB server defined

oem/get_open_incidents.sql         - get all open incidents

oem/get_credentials.sql			   - get Credential Information

oem/get_last_compliance_check_on_target.sql - get the times the compliance rules for a target are checked
                                              

Oracle Agent on Database side
--==============================================================================

oem/check_agent.sql                     - check the internal setting of the Oracle Agent
oem/check_missing_alert_log_rights.sql  - check Report to get all DB Instances with missing alert.log
oem/check_oracle_home_integrity.sql     - check if the oracle home settings on a snapshot of the target properties are the same as on the target itself 
oem/unset_all_metric_thresholds.sql     - unset all DB side server metric thresholds

-------------------------------------------------------------------------------
#