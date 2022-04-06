#!/usr/bin/env bash


set -x

split () {


file=$1
# let time for file to close
sleep 3
# give up to 10 more seconds to have the file copied
cmpt=0
# check file is valid sar file
if ! sadf-v12.5.6 -H $file; then
	return 0
fi
# get file version
version=$(sadf-v12.5.6 -H $file|awk '/from sysstat version/{print $NF}') 
#set correct binary
SADF=sadf-v$version

while :;do 
	$SADF $file >/dev/null 2>&1 && break
	sleep 1 
	cmpt=$((cmpt+1)) 
	# if counter reached 10 file is not valid and deleted
	if [[ $cmpt -eq 10 ]] ; then
		rm $file
		return 0
	fi
done


maxSamples=200 # this generate less than 5M json file, larger make filebeat to choke
start=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.time)
end=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
nodename=$($SADF -t -j $file|jq -r .sysstat.hosts[0].nodename)
startDate=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.date)
endDate=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.date)
interval=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.interval)
samples=$($SADF -t -j $file|jq -r '.sysstat.hosts[0].statistics|length')


if $SPLIT; then

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
    low=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.time)
    if [[ $low =~ "00:10:0" && $currentSample -eq 0 ]]; then
      low="00:00:00"
    fi
    if [[ $((currentSample+maxSamples)) -gt $samples ]]; then
      high=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[-1].timestamp.time)
    else
      high=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[$((currentSample+maxSamples-1))].timestamp.time)
    fi
    fileDate=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.date)
    fileTime=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[$currentSample].timestamp.time)
    echo $SADF  -t  -j  $file -- -bBdHqrRSuvwWy -m ALL -n ALL -u ALL -P ALL  -s $low -e $high
    $SADF  -t  -j  $file -- -A -I SUM  -s $low -e $high |jq . -c > ${nodename}_${fileDate}_${fileTime}.tmp
    mv ${nodename}_${fileDate}_${fileTime}.tmp ${nodename}_${fileDate}_${fileTime}.json
    currentSample=$((currentSample+maxSamples-1))
done
else
    	fileDate=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.date)
    	fileTime=$($SADF -t -j $file|jq -r .sysstat.hosts[0].statistics[0].timestamp.time)
	$SADF  -t  -j  $file -- -A -I SUM | jq . -c > ${nodename}_${fileDate}_${fileTime}.tmp
	mv ${nodename}_${fileDate}_${fileTime}.tmp ${nodename}_${fileDate}_${fileTime}.json
fi
rm $file
}


inotifywait -o output -mde attrib --excludei '.*\.json|.*\.tmp' /input
cd input
tail -f ../output|awk '{print $NF}'|while read event; do split $event ;done
