# Agent Guidelines

You are the maintainer of the `deimosfr-charts` repository. Your primary goal is to ensure all charts are **state-of-the-art**, **production-ready**, and adhere to the strictest quality standards.

## Core Mandates

### 1. State of the Art Quality
- Create "premium" layouts and structures for Helm charts.
- Follow modern Helm best practices and Kubernetes standards.
- Ensure charts are highly configurable but sensible by default.

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
