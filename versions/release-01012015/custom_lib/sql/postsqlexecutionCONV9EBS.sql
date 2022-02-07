set define on
ALTER USER "SYSTEM" IDENTIFIED BY &2;

ALTER USER "SYS" IDENTIFIED BY VALUES 'S:317021716E2E7700F890DA28303580048EC94ADF2C70D687F72AD620BB46;8A8F025737A9097A';

ALTER USER "DBSNMP" IDENTIFIED BY VALUES 'S:E252B7D3007C18A9556B4EB6EFAE4D2FE00CBC7C72E45E0ECC88553EAEAD;826AA7A5874E8D27';

-- Create directories
create or replace directory XXKK_AP_OUT_TRECS_ARCH as '/xxkk_datafiles/conv9ebs/outbound/ap/trecs/archive';
create or replace directory XXKK_ARINV_FTP_HOT_GLAZED as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/hot_glazed_ench';
create or replace directory XXKK_ARINV_FTP_WESTWARD_D_ARCH as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/westward_dough/archive';
create or replace directory XXKK_DIR_BANK_CE as '/xxkk_datafiles/prodebs/inbound/ce';
create or replace directory XXKK_INV_COST_ARCH as '/xxkk_datafiles/prodebs/inbound/inv/costing/archive';
create or replace directory XXKK_ARINV_FTP_HOT_GLAZED_ARCH as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/hot_glazed_ench/archive';
create or replace directory XXKK_ARINV_FTP_SWEET_TRAD_ARCH as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/sweet_traditions/archive';
create or replace directory XXKK_ARINV_FTP_SWEET_TRAD as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/sweet_traditions';
create or replace directory XXKK_ARINV_FTP_WESTWARD_D as '/xxkk_datafiles/prodebs/outbound/ar/ftp_invoice/westward_dough';
create or replace directory XXKK_AP_WF_CCT_ARCH as '/xxkk_datafiles/prodebs/inbound/ap/wells_fargo/credit_card_transactions/archive';
create or replace directory XXKK_AP_WF_CCT as '/xxkk_datafiles/prodebs/inbound/ap/wells_fargo/credit_card_transactions';
create or replace directory XXKK_PO_EDI850_ARCHIVE_DIR as '/xxkk_datafiles/prodebs/outbound/edi/850/archive';
create or replace directory XXKK_AREXT_AUTODEBIT_BANK_ARCH as '/xxkk_datafiles/prodebs/outbound/ar/auto_debit/archive';
create or replace directory XXKK_AREXT_AUTODEBIT_BANK_DATA as '/xxkk_datafiles/prodebs/outbound/ar/auto_debit';
create or replace directory XXKK_INV_INPRO as '/xxkk_datafiles/prodebs/outbound/inv/inprocess';
create or replace directory XXKK_PO_EDI850_DIR as '/xxkk_datafiles/prodebs/outbound/edi/850';
create or replace directory XXKK_COMSHARE_OUTBOX as '/xxkk_datafiles/prodebs/outbound/gl/comshare';
create or replace directory XXKK_INV_DATA_USAGE as '/xxkk_datafiles/prodebs/outbound/inv/inv_data_usage';
create or replace directory XXKK_INV_COM_ARCH as '/xxkk_datafiles/prodebs/outbound/inv/comshare/archive';
create or replace directory XXKK_PUR_PO_BAKEMARK as '/xxkk_datafiles/prodebs/outbound/po/bakemark';
create or replace directory XXKK_PUR_PO_SYGMA as '/xxkk_datafiles/prodebs/outbound/po/sygma';
create or replace directory XXKK_PUR_PO_BAKEMARK_ARCH as '/xxkk_datafiles/prodebs/outbound/po/bakemark/archive';
create or replace directory XXKK_PUR_PO_SYGMA_ARCH as '/xxkk_datafiles/prodebs/outbound/po/sygma/archive';
create or replace directory XXKK_FILE_LOGS as '/xxkk_datafiles/prodebs/logs';
create or replace directory XXKK_INV_COST_DIR as '/xxkk_datafiles/prodebs/outbound/inv/costing';
create or replace directory XXKK_OM_IN_PRICELIST as '/xxkk_datafiles/prodebs/inbound/om/pricelist';
create or replace directory XXKK_OM_IN_PRICELIST_ARCH as '/xxkk_datafiles/prodebs/inbound/om/pricelist/archive';
create or replace directory XXKK_OM_OUT_PRICELIST as '/xxkk_datafiles/prodebs/outbound/om/pricelist';
create or replace directory XXKK_OM_OUT_PRICELIST_ARCH as '/xxkk_datafiles/prodebs/outbound/om/pricelist/archive';
create or replace directory XXKK_AP_OUT_PROPERTY_ARCH as '/xxkk_datafiles/prodebs/outbound/ap/unclaimed_property/archive';
create or replace directory XXKK_AP_OUT_PROPERTY as '/xxkk_datafiles/prodebs/outbound/ap/unclaimed_property';
create or replace directory XXKK_COMSHARE_OUTBOX_ARCH as '/xxkk_datafiles/prodebs/outbound/gl/comshare/archive';
create or replace directory XXKK_EDI_INBOUND as '/xxkk_datafiles/prodebs/inbound/edi';
create or replace directory XXKK_AP_OUT_TRECS as '/xxkk_datafiles/prodebs/outbound/ap/trecs';
create or replace directory XXKK_INV_COST_INDIR as '/xxkk_datafiles/prodebs/inbound/inv/costing';

-- Change directory for XXKK_ARINV_FTPINV_SOURCE to $APPLCSF/out
create or replace directory XXKK_ARINV_FTPINV_SOURCE as '/u01/applmgr/CONV9EBS/inst/apps/CONV9EBS_ovpch-ascp/logs/appl/conc/out';

--------------------
-- Below code will run as apps user
--------------------
alter session set current_schema=apps;
-- Change WF_ADMIN_ROLE as apps
update apps.wf_resources set text='*'  where name='WF_ADMIN_ROLE';
-- Change scheduled requests as apps user
Update fnd_concurrent_requests set PHASE_CODE='C' , status_code='D' where status_code in ('I', 'F');
update wf_local_roles set email_address='ERPHELP@KRISPYKREME.COM' where email_address is not null;
commit;
create table fnd_userBAK as select * from fnd_user;
update fnd_user set email_address='ERPHELP@KRISPYKREME.COM' where email_address is not null;
commit;
update alr_alerts set enabled_flag='N';
commit;
update PER_ALL_PEOPLE_F set email_address='erphelp@krispykreme.com';
commit;
update hz_contact_points set email_address='erphelp@krispykreme.com';
commit;

-- SITE PROFILE CHANGES
DECLARE
   stat   BOOLEAN;
DECLARE
BEGIN
dbms_output.disable;
dbms_output.enable(1000000);
stat := FND_PROFILE.SAVE('FND_COLOR_SCHEME','tea','SITE');
stat := FND_PROFILE.SAVE('SITENAME','TEST cloned on '||to_char(trunc(sysdate),'DD-MON-YYYY'),'SITE');
stat := FND_PROFILE.SAVE('FND_PERZ_DOC_ROOT_PATH','/u01/applmgr/CONV9EBS/apps/apps_st/appl/xxkk/12.0.0/install','SITE');
stat := FND_PROFILE.SAVE('ECE_IN_FILE_PATH','/xxkk_datafiles/conv9ebs/inbound/edi/810','SITE');
stat := FND_PROFILE.SAVE('ECE_OUT_FILE_PATH','/xxkk_datafiles/conv9ebs/outbound/edi/820','SITE');
stat := FND_PROFILE.SAVE('FND_SMTP_HOST','','SITE');
stat := FND_PROFILE.SAVE('FND_SMTP_PORT','','SITE');
 IF stat
   THEN
      DBMS_OUTPUT.put_line ('Stat = TRUE - profile updated');
   ELSE
      DBMS_OUTPUT.put_line ('Stat = FALSE - profile NOT updated');
   END IF;
commit;
END;


-- Change workflow notification

-- Inbound EMail Account(IMAP) Username
UPDATE fnd_svc_comp_param_vals SET    parameter_value ='owfmail_dev' WHERE  component_parameter_id = 10054; 
-- Reply-To Address
UPDATE fnd_svc_comp_param_vals SET    parameter_value ='owfmail_dev@krispykreme.com' WHERE  component_parameter_id = 10089; 
-- Send: HTML Agent
UPDATE fnd_svc_comp_param_vals SET    parameter_value ='http://ovpch-ascp.krispycorp.com:8003' WHERE  component_parameter_id = 10066; 
-- Change Test Addresss
UPDATE fnd_svc_comp_param_vals SET    parameter_value ='erphelp@krispykreme.com' WHERE  component_parameter_id = 10093; 
commit;

exit;
