# gsar a binary sar to grafana pipeline

gsar is a data processing pipeline for sar binary files
it take as input binary sar of format "sysstat version 10.1.5"
as input, and process events thru preprocessing -> filebeat -> logstash -> elascitsearch 
to be consumed by grafana

# installation

1) create inotify docker container
```
cd inotify
docker build --no-cache . -t inotify:latest
```

2) configure input directory for sar files
```
cd docker
```
edit .env and update FILEBEATLOCALFILE with a file in your $HOME
ex: `/Users/jdoe/filebeat`

3) start docker compose stack
```
cd docker
docker compose up
```

3) put sar files under $FILEBEATLOCALFILE
After sometime you should be able to use grafana to see the graphs

4) connect to grafana on localhost:3000 and use sar dashboard

