CREATE OR REPLACE PROCEDURE DUMMY_USER.COMPRESSION_PROCEDURE (p_tsname varchar2 default null,gb_table_name varchar2(100))IS
n_bytes number;
str varchar2(100);
old_partition varchar2(100);
  CURSOR partition
  IS
    SELECT
        table_owner,partition_name, partition_position
    FROM
        dba_Tab_partitions
    where
        table_name = gb_table_name
     order by partition_position asc;
   CURSOR ch_segment (powner varchar2,psegment_name varchar2, ppartition_name varchar2)
   IS
    SELECT
        sum(bytes/1024/1024/1024) total
    FROM
        dba_segments
    where
        segment_name = psegment_name
    and
        partition_name = ppartition_name
    and
        owner = powner;
BEGIN
  FOR input IN partition
  LOOP
  open ch_segment(input.table_owner,gb_table_name,input.partition_name);
  fetch ch_segment into n_bytes;
  close ch_segment;
  select count(*) into old_partition from table_dt where c_partition = input.partition_name AND STATUS = 'FINISH';
  if old_partition = 0 then
    str:= 'ALTER TABLE ' ||  input.table_owner || '.' || gb_table_name || ' MOVE PARTITION ' || input.partition_name  ;
    if p_tsname is not null then
    str:= str || ' TABLESPACE ' || p_tsname ;
    end if;
    insert into table_dt values ( input.table_owner,gb_table_name,  input.partition_name, input.partition_position , sysdate,'START',n_bytes,str);
    commit;
    execute immediate str;
  open ch_segment(input.table_owner,gb_table_name,input.partition_name);
  fetch ch_segment into n_bytes;
  close ch_segment;
    insert into table_dt values ( input.table_owner ,gb_table_name, input.partition_name,input.partition_position ,sysdate,'FINISH',n_bytes,NULL);
    commit;
  else
    insert into table_dt values ( input.table_owner,gb_table_name,  input.partition_name, input.partition_position , sysdate,'ALREADY MOVED',n_bytes,NULL);
    commit;
  end if;
  END LOOP;
END;
/
