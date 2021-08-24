echo "******************************************************************************"
echo "Handle shutdowns." `date`
echo "docker stop --time=30 {container}" `date`
echo "******************************************************************************"
function gracefulshutdown {
  dbshut $ORACLE_HOME
}

trap gracefulshutdown SIGINT
trap gracefulshutdown SIGTERM
trap gracefulshutdown SIGKILL

echo "******************************************************************************"
echo "Define fixConfig function." `date`
echo "Fixes the config using the contents of the volume." `date`
echo "Necessary when using persistent volume as "rm" and "run" will reset the config" `date`
echo "under the ORACLE_HOME." `date`
echo "******************************************************************************"
function fixConfig {
  cp -f /db_data/${ORACLE_SID}/config/oratab /etc/oratab
  if [ ! -L ${ORACLE_HOME}/dbs/orapw${ORACLE_SID} ]; then
    ln -s /db_data/${ORACLE_SID}/config/orapw${ORACLE_SID} ${ORACLE_HOME}/dbs/orapw${ORACLE_SID}
  fi
  if [ ! -L ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ]; then
    ln -s /db_data/${ORACLE_SID}/config/spfile${ORACLE_SID}.ora ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora
  fi
  if [ ! -L ${ORACLE_BASE}/admin ]; then
    ln -s /db_data/${ORACLE_SID}/config/admin ${ORACLE_BASE}/admin
  fi
}

echo "******************************************************************************"
echo "Create networking files if they don't already exist." `date`
echo "******************************************************************************"
if [ ! -f ${ORACLE_HOME}/network/admin/listener.ora ]; then
  echo "******************************************************************************"
  echo "First start, so create networking files." `date`
  echo "******************************************************************************"

  mkdir -p /db_data/${ORACLE_SID}/dump

  cat > ${ORACLE_HOME}/network/admin/listener.ora <<EOF
LISTENER = 
(DESCRIPTION_LIST = 
  (DESCRIPTION = 
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) 
  ) 
)

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (ORACLE_HOME = ${ORACLE_HOME})
      (GLOBAL_DBNAME = ${ORACLE_SID})
      (SID_NAME = ${ORACLE_SID})
    )
  )

USE_SID_AS_SERVICE_LISTENER=on
ADR_BASE_LISTENER=/db_data/${ORACLE_SID}/dump
LOGGING_LISTENER=off
INBOUND_CONNECT_TIMEOUT_LISTENER=400
EOF

  cat > ${ORACLE_HOME}/network/admin/tnsnames.ora <<EOF
LISTENER = (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))

${ORACLE_SID}= 
(DESCRIPTION = 
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ${ORACLE_SID})
  )
)

EOF

  cat > ${ORACLE_HOME}/network/admin/sqlnet.ora <<EOF
SQLNET.INBOUND_CONNECT_TIMEOUT=400
EOF

fi

echo "******************************************************************************"
echo "Check if database already exists." `date`
echo "******************************************************************************"
if [ ! -d /db_data/${ORACLE_SID}/data01 ]; then

  # The database files don't exist, so create a new database.
  lsnrctl start

  mkdir -p /db_data/${ORACLE_SID}/data01
  mkdir -p /db_data/${ORACLE_SID}/redo01
  mkdir -p /db_data/${ORACLE_SID}/redo02
  mkdir -p /db_data/${ORACLE_SID}/admin/cntrl
  mkdir -p /db_data/${ORACLE_SID}/dump/adump
  mkdir -p /db_data/${ORACLE_SID}/archive
  mkdir -p /db_data/${ORACLE_SID}/flash_recovery_area
  mkdir -p /db_data/${ORACLE_SID}/temp
  chown -R oracle:dba /db_data

  dbca -silent -createDatabase                                                 \
    -templateName ${ORACLE_HOME}/assistants/dbca/templates/19EE_Database.rsp   \
    -sid ${ORACLE_SID} -gdbName ${ORACLE_SID}                                  \
    -sysPassword ${SYS_PASSWORD}                                               \
    -systemPassword ${SYS_PASSWORD}                                            \
    -createAsContainerDatabase false                                           \
    -emConfiguration NONE                                                      \
    -honorControlFileInitParam                                                 \
    -ignorePreReqs

  echo "******************************************************************************"
  echo "Store config files in case persistent volume is used." `date`
  echo "******************************************************************************"
  dbshut ${ORACLE_HOME}
  mkdir -p /db_data/${ORACLE_SID}/config
    
  cp /etc/oratab /db_data/${ORACLE_SID}/config/
  echo "******************************************************************************"
  echo "Flip the auto-start flag." `date`
  echo "******************************************************************************"
  sed -i -e "s|${ORACLE_SID}:${ORACLE_HOME}:N|${ORACLE_SID}:${ORACLE_HOME}:Y|g" /db_data/${ORACLE_SID}/config/oratab
  cp -f /db_data/${ORACLE_SID}/config/oratab /etc/oratab 
    
  mv ${ORACLE_HOME}/dbs/orapw${ORACLE_SID} /db_data/${ORACLE_SID}/config
  mv ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora /db_data/${ORACLE_SID}/config
  mv ${ORACLE_BASE}/admin /db_data/${ORACLE_SID}/config
  fixConfig;
  dbstart ${ORACLE_HOME}

else

  echo "******************************************************************************"
  echo "The database already exists, so start it." `date`
  echo "******************************************************************************"
  fixConfig;

  dbstart $ORACLE_HOME

fi

echo "******************************************************************************"
echo "Tail the alert log file as a background process" `date`
echo "and wait on the process so script never ends." `date`
echo "******************************************************************************"
tail -f /db_data/${ORACLE_SID}/dump/diag/rdbms/${ORACLE_SID,,}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log &
bgPID=$!
wait $bgPID
