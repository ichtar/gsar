FROM alpine:3.15.3

RUN apk add --no-cache inotify-tools bash jq coreutils tzdata
COPY monitor.sh .
COPY bin/* /usr/bin
RUN chmod +x monitor.sh && touch output
CMD ./monitor.sh
