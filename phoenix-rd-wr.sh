#!/bin/bash
################################################################################
# Program      : phoenix-rd-wr.sh
# Date Created : 01/20/2019
# Modification history:
#
# Date         Author               Description
# ===========  ===================  ============================================
# 01/20/2019   Anand Ayyasamy 	    Creation
################################################################################

# path
app_path=/data/00/sdc/audit-history-report


# Log
APP_NAME="phoenix-rd-wr"
UNDERSCORE="_"
TODAY_DATE=`date +"%Y-%m-%d"`
LOG_FILE="$app_path/logs/$APP_NAME$UNDERSCORE$TODAY_DATE.log"
touch $LOG_FILE
chmod 777 $LOG_FILE

# lib

DEP_LIB=/usr/hdp/current/phoenix-client/lib/phoenix-spark2-4.7.0.2.6.4.0-91.jar,/usr/hdp/2.6.4.0-91/phoenix/phoenix-4.7.0.2.6.4.0-91-client.jar,/usr/hdp/current/hbase-client/conf/hbase-site.xml,/usr/hdp/current/hbase-client/lib/guava-12.0.1.jar,/usr/hdp/current/hbase-client/lib/hbase-common.jar,/usr/hdp/current/hbase-client/lib/hbase-client.jar,/usr/hdp/current/hbase-client/lib/hbase-server.jar,/usr/hdp/current/hbase-client/lib/hbase-protocol.jar

extraClassPath=/usr/hdp/current/hbase-client/lib/hbase-common.jar:/usr/hdp/current/hbase-client/lib/hbase-client.jar:/usr/hdp/current/hbase-client/lib/hbase-server.jar:/usr/hdp/current/hbase-client/lib/hbase-protocol.jar:/usr/hdp/current/hbase-client/lib/guava-12.0.1.jar:/usr/hdp/current/hbase-client/lib/htrace-core-3.1.0-incubating.jar:/usr/hdp/current/phoenix-client/lib/phoenix-spark2-4.7.0.2.6.4.0-91.jar:/usr/hdp/current/phoenix-client/phoenix-client.jar:/usr/hdp/current/hbase-client/lib/metrics-core-2.2.0.jar:/usr/hdp/current/phoenix-server/lib/phoenix-core-4.7.0.2.6.4.0-91.jar


# Auth
principal=example@HADOOP.COM
keyTab=/home/usr/usr.keytab
kinit $principal -k -t $keyTab

cd $app_path/scripts

# Env Set

export SPARK_MAJOR_VERSION=2

# Submit the job

spark-submit --name $APP_NAME --jars $app_path/config/app-config.properties,$DEP_LIB \
--master yarn  --deploy-mode cluster \
--conf spark.executor.extraClassPath=$extraClassPath \
--conf spark.driver.extraClassPath=$extraClassPath \
--driver-memory 4G  --executor-cores 4 --executor-memory 4G \
--conf "spark.hadoop.yarn.timeline-service.enabled=false"  \
--conf spark.driver.extraJavaOptions=" -XX:MaxPermSize=8G "  \
--conf spark.executor.extraJavaOptions=" -XX:MaxPermSize=8G "  \
--conf spark.hadoop.fs.hdfs.impl.disable.cache="true" \
--conf spark.yarn.max.executor.failures="8" \
--files "$keyTab,$app_path/config/jaas.conf" \
--conf spark.yarn.executor.memoryOverhead="2048" \
--conf spark.driver.extraJavaOptions="-Djava.security.auth.login.config=jaas.conf"  \
--conf spark.executor.extraJavaOptions="-Djava.security.auth.login.config=jaas.conf" \
--class com.org.phoenix.on.spark.PhoenixRdWr \
$app_path/lib/phoenix-spark-1.0.0-SNAPSHOT.jar 2>&1 | tee -a $LOG_FILE

if [ "$?" -ne 0 ];then
    echo "$APP_NAME job failed"
    exit 1
else
    echo "$APP_NAME job completed successfully"
    exit 0
fi


# You are Reached !
