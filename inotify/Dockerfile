FROM alpine

RUN apk add --no-cache inotify-tools bash jq coreutils tzdata
COPY monitor.sh .
COPY sadf /usr/bin
RUN chmod +x monitor.sh && touch output
CMD ./monitor.sh
