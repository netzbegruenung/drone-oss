FROM golang:1.16-alpine3.13 AS builder

WORKDIR /opt/drone

RUN apk add --no-cache --update git ca-certificates build-base
RUN git clone --depth 1 --branch v2.0.1 https://github.com/drone/drone.git .
RUN go install -tags "oss nolimit" github.com/drone/drone/cmd/drone-server

FROM alpine:3.13

RUN apk add --no-cache --update ca-certificates

COPY --from=builder /go/bin/drone-server /go/bin/drone-server

ENTRYPOINT ["/go/bin/drone-server"]
