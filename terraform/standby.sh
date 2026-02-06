#!/bin/bash
set -e

################ OS & prereqs ################
yum update -y
yum install -y oracle-database-preinstall-19c unzip wget vim net-tools

################ Oracle user & dirs ################
groupadd oinstall || true
groupadd dba || true
useradd -g oinstall -G dba oracle || true
echo "oracle ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

mkdir -p /u01/app/oracle/product/19c/dbhome_1
mkdir -p /u01/app/oraInventory /u02/oradata /u03/redo

chown -R oracle:oinstall /u01 /u02 /u03
chmod -R 775 /u01 /u02 /u03

################ Oracle env ################
cat <<EOF >> /home/oracle/.bash_profile
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCL
export PATH=\$PATH:\$ORACLE_HOME/bin
EOF

chown oracle:oinstall /home/oracle/.bash_profile

################ Oracle DB software ################
su - oracle <<EOF
cd \$ORACLE_HOME
# unzip /tmp/LINUX.X64_193000_db_home.zip -d \$ORACLE_HOME

./runInstaller -silent \
 oracle.install.option=INSTALL_DB_SWONLY \
 oracle.install.db.InstallEdition=EE \
 UNIX_GROUP_NAME=oinstall \
 INVENTORY_LOCATION=/u01/app/oraInventory \
 ORACLE_HOME=\$ORACLE_HOME \
 ORACLE_BASE=\$ORACLE_BASE \
 DECLINE_SECURITY_UPDATES=true
EOF

/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/19c/dbhome_1/root.sh

echo "Standby VM setup complete (Oracle DB software only)"
