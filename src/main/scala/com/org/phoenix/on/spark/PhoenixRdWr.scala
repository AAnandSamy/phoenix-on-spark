/*
# Program      : PhoenixRdWr# Date Created : 01/20/2019
# Description  : This class is used to read/write the data from phoenix
# Parameters   :
#
# Modification history:
#
# Date         Author               Description
# ===========  ===================  ============================================
# 01/20/2019   Anand Ayyasamy               Creation
# ===========  ===================  ============================================
*/
package com.org.phoenix.on.spark

import java.io.FileInputStream
import java.util.Properties

import com.org.phoenix.on.spark.utils.AppConstants
import org.apache.log4j.Logger
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.functions._

import scala.collection.JavaConverters._

object PhoenixRdWr {
  private val LOGGER = Logger.getLogger(this.getClass.getName)
  private val prop = new Properties()
  prop.load(new FileInputStream("app-config.properties"))
  private val propsMap = prop.asScala

  def main(args: Array[String]): Unit = {

    val opts = Map("table" -> propsMap(AppConstants.PHOENIX_TBL), "zkUrl" -> propsMap(AppConstants.HBASE_ZK_QUORAM))

    val spark = SparkSession
      .builder()
      .appName("phoenix-rd-wr")
      .getOrCreate()

    import spark.implicits._

    try {

     /*  read from phoenix as DataFrame*/
      val df = spark.read.format("org.apache.phoenix.spark").options(opts).load
      /*  write/save DataFrame to phoenix */
       val wr = df.write.format("org.apache.phoenix.spark").mode("overwrite").options(opts).save()

    }

    catch {
      case exception: Exception =>
        LOGGER.error(exception.printStackTrace())
        sys.exit(1)

    }


  }


}
