FROM golang:1.16-alpine3.13 AS builder

WORKDIR /opt/drone

RUN apk add --no-cache --update git ca-certificates build-base
RUN git clone --depth 1 --branch v2.0.1 https://github.com/drone/drone.git .
RUN go install -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM alpine:3.13

EXPOSE 80 443
VOLUME /data

# from https://github.com/drone/drone/blob/ca454594021099909fb4ee9471720cacfe3207bd/docker/Dockerfile.server.linux.amd64
ENV GODEBUG netdns=go
ENV XDG_CACHE_HOME /data
ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /data/database.sqlite
ENV DRONE_RUNNER_OS=linux
ENV DRONE_RUNNER_ARCH=amd64
ENV DRONE_SERVER_PORT=:80
ENV DRONE_SERVER_HOST=localhost

RUN apk add --no-cache --update ca-certificates

COPY --from=builder /go/bin/drone-server /go/bin/drone-server

ENTRYPOINT ["/go/bin/drone-server"]
