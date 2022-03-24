#!/usr/bin/env bash

# a script that take sar file as input and output a json file to be slurped by filebeat

#set -x

[[ $1 == "" ]] && exit 1
[[ -f $1 ]] || exit 1

file=$1
maxSamples=200 # this generate less than 5M json file, larger make filebeat to choke
start=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.time)
end=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
nodename=$(sadf -t -j $file|jq -r .sysstat.hosts[0].nodename)
startDate=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.date)
endDate=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.date)
interval=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.interval)
samples=$(sadf -t -j $file|jq -r '.sysstat.hosts[0].statistics|length')

increment=$(( interval * maxSamples))


start_ts=$(date -d "$start $startDate" +%s)
end_ts=$(date -d "$end $endDate" +%s)

for (( c=$start_ts; c<$end_ts; c=$((c + increment)) )) ; do
    low=$(date -d @$c '+%H:%M:%S')
    fileDate=$(date -d @$c '+%Y%m%d-%H%M%S')
    high=$(date -d @$((c+increment)) '+%H:%M:%S')
    sadf  -T  -j  $file -- -pbBdFHqrRSuvwWy -m ALL -n ALL -u ALL -P ALL  -s $low -e $high |jq . -c > ${nodename}_${fileDate}.json
done
