#!/usr/bin/env bash

table_info="select concat(DBS.NAME, '.', TBLS.TBL_NAME) as TABLE_NAME, PARTITIONS.PART_NAME, SDS.LOCATION
from PARTITIONS
left join SDS on SDS.SD_ID = PARTITIONS.SD_ID
left join TBLS on TBLS.TBL_ID = PARTITIONS.TBL_ID
left join DBS on DBS.DB_ID = TBLS.DB_ID
where SDS.LOCATION like '%hdfs://nameservice1/externaldata/%'
order by TABLE_NAME, PARTITIONS.PART_NAME;"

time_ago=$(date -d "7 days ago" +%Y%m%d)
time_cur=$(date +%Y%m%d)

mysql -hsit-newbdata-srv2 -uhive -phivedfsit#2021 --silent -e "use hive; $table_info" > table_info.log
if [[ $? != 0 ]]; then
  echo "${time_cur}, failed to get hive table info." >> hive_tables_cleanup.log
  exit 1
fi

oldIFS=$IFS
IFS=$'\t'
while read table_name part_name location
do
  part_time=$(echo ${part_name} |awk -F'=' '{print $2}')
  if [[ ${part_time} < ${time_ago} ]]; then
    hive -e "alter table ${table_name} drop if exists partition (${part_name});"
    if [[ $? != 0 ]]; then
      echo "${time_cur}, table:${table_name} partition:${part_name}, failed to drop table partition." >> hive_tables_cleanup.log
      exit 1
    fi
    hdfs dfs -rm -r ${location}
    if [[ $? != 0 ]]; then
      echo "${time_cur}, location:${location}, failed to delete hdfs location." >> hive_tables_cleanup.log
      exit 1
    fi
  fi
done < table_info.log
IFS=$oldIFS
