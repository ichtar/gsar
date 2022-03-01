#!/usr/bin/env bash

set -x

[[ $1 == "" ]] && exit 1
[[ -f $1 ]] || exit 1

file=$1
maxSamples=200
start=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.time)
end=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
nodename=$(sadf -t -j $file|jq -r .sysstat.hosts[0].nodename)
filedate=$(sadf -t -j $file|jq -r '.sysstat.hosts[0]."file-date"')
interval=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.interval)

echo $filedate $nodename
start_ts=$(date -d $start +%s)
end_ts=$(date -d $end +%s)
samples=$(( (end_ts-start_ts)/interval ))
iteration=$(( (samples)/100 ))
echo $start_ts $end_ts $interval $iteration $samples

counter=$start_ts
if [[ $samples -lt $maxSamples ]]; then
  delta=$(( interval * samples ))
else
  delta=$(( interval * maxSamples ))
fi

#while [[ $counter -lt $end_ts ]]; do
for (( c=1; c<=$iteration; c++ ))
do
low=$(date -d @$counter '+%H:%M:%S')
high=$(date -d @$((counter+delta+10)) '+%H:%M:%S')
echo $low $high
sadf  -T  -j  $file -- -pbBdFHqrRSuvwWy -m ALL -n ALL -u ALL -P ALL  -s $low -e $high|jq . -c > ${nodename}_${filedate}_$low.json
counter=$(( counter + delta ))
done
