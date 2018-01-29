FROM golang:1.9-alpine as builder

WORKDIR /go/src/hadoop_exporter
RUN apk --update --no-cache add git

COPY . .
RUN go get -v -d
RUN CGO_ENABLED=0 GOOS=linux go build -a -v -installsuffix cgo -o namenode_exporter namenode_exporter.go
RUN CGO_ENABLED=0 GOOS=linux go build -a -v -installsuffix cgo -o resourcemanager_exporter resourcemanager_exporter.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates && \
    mkdir /app

WORKDIR /app/
COPY --from=builder /go/src/hadoop_exporter/namenode_exporter namenode_exporter
COPY --from=builder /go/src/hadoop_exporter/resourcemanager_exporter resourcemanager_exporter
