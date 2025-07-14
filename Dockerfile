# Build stage
FROM golang:latest AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go build -o certstream-server-go ./cmd/certstream-server-go

# Final image
FROM alpine
WORKDIR /app

ENV USER=certstreamserver
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

COPY --from=builder /app/certstream-server-go /app/certstream-server-go
COPY ./config.sample.yaml /app/config.yaml

USER certstreamserver:certstreamserver
EXPOSE 8080
ENTRYPOINT ["/app/certstream-server-go"]