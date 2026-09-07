FROM golang:alpine AS builder

RUN apk add --no-cache upx

WORKDIR /app
COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o webserver main.go

RUN upx --best --lzma webserver

FROM scratch

COPY --from=builder /app/webserver /webserver


EXPOSE 8080

ENTRYPOINT ["/webserver"]