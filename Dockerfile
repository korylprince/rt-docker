# build go dependencies
FROM golang:1-alpine as builder

RUN apk add --no-cache git

RUN go install github.com/korylprince/fileenv@v1.1.0
RUN go install github.com/korylprince/twilio-send-sms@v1.0.0

# build rt5
FROM alpine:3.18 as rt5-builder

ARG VERSION
ARG ALPINEDEPS
ARG CPANDEPS

RUN wget https://download.bestpractical.com/pub/rt/release/rt-$VERSION.tar.gz && \
    tar xzf /rt-$VERSION.tar.gz && \
    rm /rt-$VERSION.tar.gz

WORKDIR /rt-$VERSION

RUN apk add \
        alpine-sdk \
        graphviz \
        perl-dev \
        perl-app-cpanminus \
        $ALPINEDEPS

RUN cpanm -n $CPANDEPS

RUN ./configure --disable-gpg && \
    make testdeps && \
    make install

# build image
FROM alpine:3.18

ARG ALPINEDEPS

COPY --from=builder /go/bin/fileenv /
COPY --from=builder /go/bin/twilio-send-sms /send-sms
COPY --from=rt5-builder /opt/rt5 /opt/rt5
COPY --from=rt5-builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=rt5-builder /usr/local/share/perl5 /usr/local/share/perl5

RUN apk add --no-cache \
    bash python3 opensmtpd ca-certificates mysql-client graphviz html2text $ALPINEDEPS

RUN mkdir /shredder

COPY Web_Local.pm /opt/rt5/lib/RT/Interface/
COPY LocalConfig.pm /opt/rt5/etc/RT_SiteConfig.d/
COPY run.sh /
COPY rt-search-id /

CMD ["/fileenv", "bash", "/run.sh"]
