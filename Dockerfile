FROM golang:1.12-alpine as builder

RUN apk add --no-cache git

RUN git clone --branch "v1.1" --single-branch --depth 1 \
    https://github.com/korylprince/fileenv.git /go/src/github.com/korylprince/fileenv

RUN git clone --branch "v1.0" --single-branch --depth 1 \
    https://github.com/korylprince/twilio-send-sms.git /go/src/github.com/korylprince/twilio-send-sms

RUN go install github.com/korylprince/fileenv
RUN go install github.com/korylprince/twilio-send-sms

# build image
FROM alpine:3.10

COPY --from=builder /go/bin/fileenv /
COPY --from=builder /go/bin/twilio-send-sms /send-sms

RUN apk add --no-cache bash python3 perl-ldap perl-gdtextutil perl-gdgraph opensmtpd ca-certificates mysql-client && \
    wget http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/rt4-4.4.3-r0.apk && \
    wget http://dl-cdn.alpinelinux.org/alpine/edge/testing/x86_64/perl-http-parser-xs-0.17-r0.apk && \
    wget http://dl-cdn.alpinelinux.org/alpine/edge/testing/x86_64/perl-starman-0.4014-r0.apk && \
    apk add --no-cache /rt4-4.4.3-r0.apk /perl-http-parser-xs-0.17-r0.apk /perl-starman-0.4014-r0.apk && \
    rm /*.apk && \
    # patch to use utf8mb4 encoding
    sed -i "s/SET NAMES 'utf8'/SET NAMES 'utf8mb4'/g" /usr/lib/rt4/RT/Handle.pm

RUN mkdir /shredder

COPY LocalConfig.pm /etc/rt4/RT_SiteConfig.d/
COPY run.sh /
COPY rt-search-id /

CMD ["/fileenv", "bash", "/run.sh"]
