FROM golang:1.14-alpine as builder

ARG CADDY_VERSION="1.0.5"

RUN apk add --no-cache git

WORKDIR /caddy

# copy pluggins file
COPY main.go /caddy/main.go

RUN go mod init caddy
RUN go get github.com/caddyserver/caddy@"v$CADDY_VERSION"

# create caddy binary in current folder
RUN go build

FROM alpine:3.6

# install deps
RUN apk add --no-cache --no-progress curl tini ca-certificates

# copy caddy binary
COPY --from=builder /caddy/caddy /usr/bin/caddy

# list plugins
RUN /usr/bin/caddy -plugins

# static files volume
VOLUME ["/www"]
WORKDIR /www

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.md /www/index.md

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["caddy", "-agree", "--conf", "/etc/caddy/Caddyfile"]
