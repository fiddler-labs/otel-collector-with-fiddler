# Build stage
FROM golang:1.23-alpine AS builder

# Install git for fetching dependencies
RUN apk add --no-cache git

# Install the OpenTelemetry Collector Builder
RUN go install go.opentelemetry.io/collector/cmd/builder@v0.132.0

# Set working directory
WORKDIR /build

# Copy the builder config
COPY fiddler-collector-builder-config.yaml .

RUN go clean -modcache && \
    go clean -cache && \
    builder --config fiddler-collector-builder-config.yaml

# Runtime stage
FROM alpine:latest

# Install CA certificates for HTTPS connections
RUN apk add --no-cache ca-certificates

# Create a non-root user to run the collector
RUN adduser -D -u 10001 otel

# Set working directory
WORKDIR /etc/otelcol-dev-fiddler

# Copy the built binary from the builder stage
COPY --from=builder /build/otelcol-dev-fiddler/otelcol-dev-fiddler /usr/local/bin/

# Use the non-root user
USER 10001

# Expose common OTLP ports
EXPOSE 4317 4318 8888 9009

# Set the entrypoint to run the collector
ENTRYPOINT ["otelcol-dev-fiddler"]
CMD ["--config", "/etc/otelcol-dev-fiddler/config.yaml"] 