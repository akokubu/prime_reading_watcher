#!/bin/bash
filename=$1
date=`echo ${filename} | sed  -e 's/[^0-9]//g'`
date=${date:0:4}-${date:4:2}-${date:6:2}
for asin in `cat ${filename}`
do
  curl -s -H "Content-type: application/json" -X POST localhost:4000/api/books -d "{ \"book\": { \"asin\": \"${asin}\", \"update_date\": \"${date}\", \"add_date\": \"${date}\"} }"
done
