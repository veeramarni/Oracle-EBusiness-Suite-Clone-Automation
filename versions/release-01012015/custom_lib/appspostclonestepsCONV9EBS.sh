appspostclonesteps()
{


if [ "${tier}" -eq 1 ]
then
   echo "		running post step for tier ${tier}.."
   # Add steps that need to run on TIER 1
 elif [ "${tier}" -eq 2 ]
 then
   echo "		running post step for tier ${tier}.."
   # Add steps that need to run on TIER 2
rm $XXKK_TOP/bin/XXKK_GLINF_GENERIC
rm $XXKK_TOP/bin/XXKK_GENERIC_MAILING
rm $XXKK_TOP/bin/XXKK_GEN_VALID_ERR_HANDLING
rm $XXKK_TOP/bin/XXKK_OMINT_SYGMA_ORD_IMP_LOAD
rm $XXKK_TOP/bin/XXKK_FININT_EDI820_PROG
rm $XXKK_TOP/bin/XXKK_FININT_EDI810
rm $XXKK_TOP/bin/XXKK_INVINT_COST_UPDATE
rm $XXKK_TOP/bin/XXKK_GENERIC_SQLLDR
rm $XXKK_TOP/bin/XXKK_FININT_ADP_HOST
rm $XXKK_TOP/bin/XXKK_AP_INT_APLOADER_INV_LOAD
rm $XXKK_TOP/bin/XXKK_AP_WELLS_FARGO_FILE_LOAD
rm $XXKK_TOP/bin/XXKK_RCVINT_FRSTORES_LOAD
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_GLINF_GENERIC
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_GENERIC_MAILING
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_GEN_VALID_ERR_HANDLING
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_OMINT_SYGMA_ORD_IMP_LOAD
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_FININT_EDI820_PROG
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_FININT_EDI810
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_FININT_ADP_HOST
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_AP_INT_APLOADER_INV_LOAD
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_AP_WELLS_FARGO_FILE_LOAD
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_RCVINT_FRSTORES_LOAD
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_GENERIC_SQLLDR
ln -s $FND_TOP/bin/fndcpesr $XXKK_TOP/bin/XXKK_INVINT_COST_UPDATE

#Startup MWA services,
$ADMIN_SCRIPTS_HOME/mwactl.sh start 10218 >${logfilepath}/mwactl1.log 2>&1
$ADMIN_SCRIPTS_HOME/mwactl.sh start 10220  >${logfilepath}/mwactl2.log 2>&1
$ADMIN_SCRIPTS_HOME/mwactl.sh start 10222  >${logfilepath}/mwactl3.log 2>&1
nohup $ADMIN_SCRIPTS_HOME/mwactl.sh start_dispatcher 10809 1>/dev/null 2>/dev/null &
fi
}