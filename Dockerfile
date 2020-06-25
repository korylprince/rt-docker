FROM golang:1.14-alpine as builder

RUN apk add --no-cache git

RUN git clone --branch "v1.1" --single-branch --depth 1 \
    https://github.com/korylprince/fileenv.git /go/src/github.com/korylprince/fileenv

RUN git clone --branch "v1.0" --single-branch --depth 1 \
    https://github.com/korylprince/twilio-send-sms.git /go/src/github.com/korylprince/twilio-send-sms

RUN go install github.com/korylprince/fileenv
RUN go install github.com/korylprince/twilio-send-sms

# build image
FROM alpine:3.12

COPY --from=builder /go/bin/fileenv /
COPY --from=builder /go/bin/twilio-send-sms /send-sms

RUN apk add --no-cache bash python3 perl-ldap perl-gdtextutil perl-gdgraph opensmtpd ca-certificates mysql-client \
    perl-http-headers-fast perl-cookie-baker perl-starlet \
    perl-app-cpanminus make \
    rt4=4.4.4-r3 && \
    # needed for Plack
    cpanm HTTP::Entity::Parser && \
    # patch to use utf8mb4 encoding
    sed -i "s/SET NAMES 'utf8'/SET NAMES 'utf8mb4'/g" /usr/lib/rt4/RT/Handle.pm

RUN mkdir /shredder

COPY Web_Local.pm /usr/lib/rt4/RT/Interface/
COPY LocalConfig.pm /etc/rt4/RT_SiteConfig.d/
COPY run.sh /
COPY rt-search-id /

CMD ["/fileenv", "bash", "/run.sh"]
