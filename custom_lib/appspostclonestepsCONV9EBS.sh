appspostclonesteps()
{
cd $XXKK_TOP/bin
rm XXKK_GLINF_GENERIC XXKK_GENERIC_MAILING XXKK_GEN_VALID_ERR_HANDLING
 XXKK_OMINT_SYGMA_ORD_IMP_LOAD XXKK_FININT_EDI820_PROG XXKK_FININT_EDI810 
ln -s $FND_TOP/bin/fndcpesr XXKK_GLINF_GENERIC
ln -s $FND_TOP/bin/fndcpesr XXKK_GENERIC_MAILING
ln -s $FND_TOP/bin/fndcpesr XXKK_GEN_VALID_ERR_HANDLING
ln -s $FND_TOP/bin/fndcpesr XXKK_OMINT_SYGMA_ORD_IMP_LOAD
ln -s $FND_TOP/bin/fndcpesr XXKK_FININT_EDI820_PROG
ln -s $FND_TOP/bin/fndcpesr XXKK_FININT_EDI810
ln -s $FND_TOP/bin/fndcpesr XXKK_FININT_ADP_HOST
ln -s $FND_TOP/bin/fndcpesr XXKK_AP_INT_APLOADER_INV_LOAD
ln -s $FND_TOP/bin/fndcpesr XXKK_AP_WELLS_FARGO_FILE_LOAD
ln -s $FND_TOP/bin/fndcpesr XXKK_RCVINT_FRSTORES_LOAD
ln -s $FND_TOP/bin/fndcpesr XXKK_GENERIC_SQLLDR
ln -s $FND_TOP/bin/fndcpesr  XXKK_GLINF_GENERIC
ln -s $FND_TOP/bin/fndcpesr  XXKK_INVINT_COST_UPDATE
}