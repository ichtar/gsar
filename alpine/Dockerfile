FROM alpine:3.15.3 as builder

RUN apk add --no-cache alpine-sdk linux-headers musl-locales bash && git clone https://github.com/sysstat/sysstat.git

FROM builder
COPY compile.sh .
RUN chmod +x compile.sh

#CMD ["tail", "-f", "/dev/null"]
CMD ["./compile.sh"]

