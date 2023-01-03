# Oracle-partition-compression-procedure

This plsql procedure migrates old partitions of the table to compressed new blocks. According to the parameters, it passes to a new tablespace or does this work inside the current tablespace. After compression, read, write, delete and update operations slow down partially. It is recommended not to do it in dense OLTP environments, can be used to compress archival data. You can save from storage up to %60.

How to use it ?

--> If you create a new table, check **partitioned_clob_compressed_table.sql**
    
   
1. If you compress cold data by partitions, first you need to change table's attiribute to compress. This command changes the behavior of the table. It does not compress the old data, it compresses the new incoming data.
    
     ALTER TABLE DUMMY_USER.DUMMY_TABLE COMPRESS; 
     
2. Create logging table for procedure so we can obtain how much we have gained from storage and if the job is interrupted, it sees which partition it has left and continues from there so this procedure is **Idempotent**. For logging table, see **log_table.sql**
**You can check partition_final.png to see example result of compression :)**
    
3. Call procedure from command line with nohup to make sure that it doesn't crash into timeout or get killed by another cron job. If you don't specify the new tablespace, it moves partitions in current one.


  ## Points you should consider :)

    1. You can always kill the session, when the procedure is called again, it will start where it left off by reading from the log table.
    
    2. This procedure move data between blocks so it means IO load, take this load into account while working and prefer the times when the system is not very busy.
    
    3. If you have indexes on partitions which are compressed, you have to rebuild to reuse it. Moving partitions make indexes unusable for once.
    
    4. In tables which contains CLOB fields, use deduplicate option in lob segments. DB_SECUREFILE must be "PREFERRED" to use this feature.
    
    5. After compression, you have 2 options. First, you can migrate all data from old to new one and drop old tablespace completely or you can shrink your datafiles if you compressed your data into current tablespace.
