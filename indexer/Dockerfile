# build go dependencies
FROM golang:1-alpine as builder

RUN apk add --no-cache git

RUN go install github.com/korylprince/fileenv@v1.1.0
RUN go install github.com/korylprince/run-every@v1.0.0

# use builder from main Dockerfile
FROM rt5:build as rt5-builder

FROM alpine:3.18

ARG ALPINEDEPS

COPY --from=builder /go/bin/fileenv /
COPY --from=builder /go/bin/run-every /
COPY --from=rt5-builder /opt/rt5 /opt/rt5
COPY --from=rt5-builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=rt5-builder /usr/local/share/perl5 /usr/local/share/perl5

RUN apk add --no-cache bash mysql-client html2text $ALPINEDEPS

COPY ./indexer/LocalConfig.pm /opt/rt5/etc/RT_SiteConfig.d/
COPY ./indexer/run.sh /

CMD ["/fileenv", "bash", "/run.sh"]
