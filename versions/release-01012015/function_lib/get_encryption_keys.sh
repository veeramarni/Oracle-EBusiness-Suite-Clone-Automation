old_get_encryption_keys () {
  old_write_passf "${PASSWD}"
  local KEYS=`/bin/su oracle -c "/bin/cat \"${BACKUP_DIR}/keys\" \
             | /usr/bin/openssl aes-256-cbc -d -kfile \"${PASSF}\" \
               -iv \"${IV_KEYS}\""`
  old_erase_passf

  # Verify that keys contain only expected characters
  local EXPECTED_RE="^[A-Za-f0-9_]{64,64}$"
  if ! [[ "${KEYS}" =~ "${EXPECTED_RE}" ]]; then
    echo "Internal error: unexpected key format"
    exit 1
  fi

  KEY_CFG="${KEYS:0:32}"
  KEY_DB="${KEYS:32:32}"
}
