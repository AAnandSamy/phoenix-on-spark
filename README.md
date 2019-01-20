# phoenix-on-spark

- Make a Phoenix connection 
    `val opts = Map("table" -> "tbl_name", "zkUrl" -> "localhost:2181")`

### Reading from Phoenix Tables
 - Read from phoenix as DataFrame
 `val df = spark.read.format("org.apache.phoenix.spark").options(opts).load`


### Saving/Writing DataFrames to Phoenix Tables

- Write/save DataFrame to phoenix
`val wr = df.write.format("org.apache.phoenix.spark").mode("overwrite").options(opts).save()`