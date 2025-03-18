# Using the Fiddler Receiver

A simple stack for testing the Fiddler receiver [under development] for OpenTelemetry.

The source code for the Fiddler receiver is available on a fork of the upstream OpenTelemetry Collector Contrib repository under Fiddler Labs. You can check it out [here](https://github.com/fiddler-labs/opentelemetry-collector-contrib/tree/fiddler-receiver-basic-implementation/receiver/fiddlerreceiver)

## Quick Setup

1. Copy the example configuration file:
   ```bash
   cp otel-config.yaml.example otel-config.yaml
   ```

2. Edit `otel-config.yaml` to set your Fiddler credentials:
   ```yaml
   receivers:
     fiddler:
       endpoint: "your-fiddler-endpoint"  # https://docs.fiddler.ai/client-guide/installation-and-setup#find-your-url
       token: "your-api-token"           # https://docs.fiddler.ai/client-guide/installation-and-setup#find-your-authorization-token
       interval: "300s"  # Set to 5 minutes for testing (default is 3600s/1 hour)
       enabled_metric_types: ["traffic", "drift", "service_metrics", "performance", "statistic", "data_integrity"]
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

## Custom Collector Configuration

The `fiddler-collector-builder-config.yaml` file defines how to build our custom OpenTelemetry Collector:

```yaml
receivers:
  - gomod:
      github.com/open-telemetry/opentelemetry-collector-contrib/receiver/fiddlerreceiver v0.87.0

replaces:
  - github.com/open-telemetry/opentelemetry-collector-contrib/receiver/fiddlerreceiver => github.com/fiddler-labs/opentelemetry-collector-contrib/receiver/fiddlerreceiver fiddler-receiver-basic-implementation
```

The **replaces** section redirects the build process to use Fiddler's implementation of the receiver rather than the upstream OpenTelemetry Collector where the Fiddler receiver implementation is not yet merged.

This approach allows us to use the standard OpenTelemetry Collector builder while incorporating Fiddler's custom receiver component.

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
   - Setup dahsboards as you wish with the following example queries:
     - `{metric_type="data_integrity", model="$model", project="$project"}[1d]`
     - `{metric_type="drift", model="$model", project="$project"}[1d]`
     - `{metric_type="service_metrics", model="$model", project="$project"}[1d]`
     - `{metric_type="performance", model="$model", project="$project"}[1d]`