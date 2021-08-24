# This patch script should only be used for a clean installation.
# It doesn't patch existing databases.
echo "******************************************************************************"
echo "Patch Oracle Software." `date`
echo "******************************************************************************"
 
# Adjust to suit your patch level.
export PATH=${ORACLE_HOME}/OPatch:${PATH}
export OPATCH_FILE="p6880880_122010_Linux-x86-64.zip"
export PATCH_FILE="p${PATCH_ID}_190000_Linux-x86-64.zip"
export PATCH_TOP=${PATCH_DIR}/${PATCH_ID}

if [ "${INSTALL_PATCH}" = true ] ; then

  echo "******************************************************************************"
  echo "Prepare opatch." `date`
  echo "******************************************************************************"
  
  cd ${ORACLE_HOME}
  unzip -oq ${PATCH_DIR}/${OPATCH_FILE}
  
  echo "******************************************************************************"
  echo "Unzip software." `date`
  echo "******************************************************************************"
  
  cd ${PATCH_DIR}
  unzip -oq ${PATCH_FILE}
  
  echo "******************************************************************************"
  echo "Apply patches." `date`
  echo "******************************************************************************"
  
  cd ${PATCH_TOP}
  opatch prereq CheckConflictAgainstOHWithDetail -ph ./
  opatch apply -silent
  
fi