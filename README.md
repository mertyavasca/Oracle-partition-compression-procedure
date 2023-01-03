# Oracle-partition-compression-procedure

This plsql procedure migrates old partitions of the table to compressed new blocks, According to the parameters, it passes to a new tablespace or does this work inside the current tablespace. After compression read, write, delete and update operations slow down partially. It is recommended not to do it in dense OLTP environments, but to do it in archive quality cold data.

How to use it ?

    --> If you create a new table, check example_compressed_table.sql
    
    1. If you compress cold data by partitions, first you need to change table's attiribute to compress. This command changes the behavior of the table. It does not compress the old data, it compresses the new incoming data.
    
     ALTER TABLE DUMMY_USER.DUMMY_TABLE COMPRESS; 
     
    2. Create logging table for procedure so we can obtain how much we have gained from storage and if the job is interrupted, it sees which partition it has left and continues from there so this procedure is Idempotent
    
    3. Call procedure from command line with nohup to make sure that it doesn't crash into timeout or get killed by another cron job.
