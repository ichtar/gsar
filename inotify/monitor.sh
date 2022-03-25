#!/usr/bin/env bash


set -x

split () {


file=$1
# let time for file to close
sleep 3
# give up to 10 more seconds to have the file copied
cmpt=0
while :;do 
	sadf $file >/dev/null 2>&1 && break
	sleep 1 
	cmpt=$((cmpt+1)) 
	[[ $cmpt -eq 10 ]] && break
done

maxSamples=200 # this generate less than 5M json file, larger make filebeat to choke
start=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.time)
end=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
nodename=$(sadf -t -j $file|jq -r .sysstat.hosts[0].nodename)
startDate=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.date)
endDate=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.date)
interval=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.interval)
samples=$(sadf -t -j $file|jq -r '.sysstat.hosts[0].statistics|length')

if [[ $samples -gt $maxSamples ]]; then
  increment=$(( interval * maxSamples))
else
  increment=$(( interval * samples ))
fi


start_ts=$(date -d "$start $startDate" +%s)
end_ts=$(date -d "$end $endDate" +%s)
currentSample=0
echo $interval
for (( c=$start_ts; c<$end_ts; c=$((c + increment)) )) ; do
    low=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.time)
    if [[ $low =~ "00:10:0" && $currentSample -eq 0 ]]; then
      low="00:00:00"
    fi
    if [[ $((currentSample+maxSamples)) -gt $samples ]]; then
      high=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
    else
      high=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[$((currentSample+maxSamples-1))].timestamp.time)
    fi
    fileDate=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.date)
    fileTime=$(sadf -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.time)
    echo sadf  -T  -j  $file -- -bBdHqrRSuvwWy -m ALL -n ALL -u ALL -P ALL  -s $low -e $high
    sadf  -T  -j  $file -- -bBdHqrRSuvwWy -m ALL -n ALL -u ALL -P ALL  -s $low -e $high |jq . -c > ${nodename}_${fileDate}_${fileTime}.json
    currentSample=$((currentSample+maxSamples-1))
done
}


inotifywait -o output -mde create --excludei '.*\.json|.*\.tmp' /input
cd input
tail -f ../output|awk '{print $NF}'|while read event; do split $event ;done
