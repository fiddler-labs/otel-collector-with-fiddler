# OpenTelemetry Monitoring with Fiddler Receiver

A simple stack for testing the Fiddler receiver [under development] for OpenTelemetry.

## Quick Setup

1. Copy the example configuration file:
   ```bash
   cp otel-config.yaml.example otel-config.yaml
   ```

2. Edit `otel-config.yaml` to set your Fiddler credentials:
   ```yaml
   receivers:
     fiddler:
       endpoint: "your-fiddler-endpoint"
       token: "your-api-token"
       interval: "300s"  # Set to 5 minutes for testing (default is 3600s/1 hour)
       enabled_metrics: ["traffic", "drift", "service_metrics", "performance", "statistics"]
   ```

3. Start the stack:
   ```bash
   docker-compose up -d
   ```

4. Access services:
   - Grafana: http://localhost:3000

## OpenTelemetry Collector Overview

The OpenTelemetry Collector is a vendor-agnostic implementation that can receive, process, and export telemetry data.

Key components:
- **Receivers**: Input plugins that collect data (in our case, the Fiddler receiver)
- **Exporters**: Output plugins that send data to storage backends (we use OTLP HTTP to Mimir)
- **Pipelines**: Connect receivers to exporters and define the data flow

Our setup uses a custom-built collector with a specialized Fiddler receiver to collect AI model monitoring metrics.

## Viewing Data in Grafana

1. Open Grafana at http://localhost:3000 (default credentials: admin/admin)

2. Add Mimir as a data source:
   - Click on "Configuration" (gear icon) → "Data sources"
   - Click "Add data source"
   - Select "Prometheus"
   - Set URL to `http://mimir:9009/prometheus`
   - Click "Save & Test"

3. Create dashboards:
   - Click "+" → "Dashboard"
   - Click "Add visualization"
   - Select the Mimir data source
   - Use Prometheus Query Language (PromQL) to query your Fiddler metrics
   - Example query: `fiddler_traffic_total` or `fiddler_drift_percentage`
