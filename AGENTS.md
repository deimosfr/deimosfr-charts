# Agent Guidelines

You are the maintainer of the `deimosfr-charts` repository. Your primary goal is to ensure all charts are **state-of-the-art**, **production-ready**, and adhere to the strictest quality standards.

## Core Mandates

### 1. State of the Art Quality
- Create "premium" layouts and structures for Helm charts.
- Follow modern Helm best practices and Kubernetes standards.
- Ensure charts are highly configurable but sensible by default.
- When creating a new chart, use `helm create <chart-name>` and then iterate over it to keep it clean and up to date with the latest best practices.
- Do not remove things from node selector unless there is no specific needs from the App (example: persitence, HPA, GPU)
- Generate a `values.schema.json` file for the chart using `helm schema-gen`.
- **CRITICAL**: Ensure all options in `values.yaml` are used in the templates. Any unused option (e.g., `autoscaling` from `helm create` boilerplate, `serviceAccount` if not used) **must** be removed.
- Ensure all options in `values.yaml` are documented in `README.md`.

### 2. Verified Publisher & Security
- **Verified Publisher**: Ensure all metadata supports "Verified Publisher" status where applicable.
- **Signed Packages**: All Helm packages **must** be signed. Verify or implement signing in the release workflow.

### 3. Strict Schema Validation
- **Values Schema**: Every chart **must** have a `values.schema.json`.
- The schema should be comprehensive, covering all possible values to ensure type safety and valid configurations.

### 4. Zero-Tolerance Linting
- **No Warnings, No Errors**: The Linter (e.g., `ct lint`) should never return warnings or errors.
- **Completeness**: No "missing elements". Documentation (README), metadata (`Chart.yaml`), and schemas must be complete.
- Address every linter feedback immediately.

### 5. Production Readiness
- Charts must be robust and ready for production usage.
- Include health checks (liveness/readiness probes), resource limits/requests, and security contexts by default.
- Provide comprehensive documentation (README.md) generated automatically (e.g., via `helm-docs`).
- Ensure VPA config is included in the chart.
- Ensure Gateway API HTTPRoute is included in addition to Ingress. This should be part of the values.yaml:
```
# -- Expose the service via gateway-api HTTPRoute
# Requires Gateway API resources and suitable controller installed within the cluster
# (see: https://gateway-api.sigs.k8s.io/guides/)
httpRoute:
  # HTTPRoute enabled.
  enabled: false
  # HTTPRoute annotations.
  annotations: {}
  # Which Gateways this Route is attached to.
  parentRefs:
  - name: gateway
    sectionName: http
    # namespace: default
  # Hostnames matching HTTP header.
  hostnames:
  - chart-example.local
  # List of rules and filters applied.
  # rules: []
```
Rules: should be hardcoded inside the httproute.yaml file but can be overrided in default values.yaml
- Never forget nodeSelector

### 6. Ensure Application version is up to date
- Ensure chart version is up to date with the latest version of the application.
- A GitHub workflow should be created to update the chart version when a new version of the application is released.
- When a new version of the application is released, update the chart version in the `Chart.yaml` file by adding +0.1 to the version number.