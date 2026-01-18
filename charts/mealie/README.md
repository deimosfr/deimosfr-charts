# Mealie Helm Chart

![Version: 3.9.2](https://img.shields.io/badge/Version-3.9.2-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: v3.9.2](https://img.shields.io/badge/AppVersion-v3.9.2-informational?style=flat-square)

Mealie is a self-hosted recipe manager and meal planner with a RestAPI backend and a reactive frontend application built in Vue for a pleasant user experience for the whole family.

## Introduction

This chart bootstraps a [Mealie](https://mealie.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release deimosfr/mealie
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

## Configuration

The following table lists the configurable parameters of the Mealie chart and their default values.

| Key                 | Type   | Default                           | Description                                |
| ------------------- | ------ | --------------------------------- | ------------------------------------------ |
| image.repository    | string | `"ghcr.io/mealie-recipes/mealie"` | Mealie image repository                    |
| image.tag           | string | `""`                              | Mealie image tag (defaults to AppVersion)  |
| service.port        | int    | `9000`                            | Kubernetes Service port                    |
| persistence.enabled | bool   | `true`                            | Enable persistence using PVC               |
| persistence.size    | string | `"10Gi"`                          | Size of the PVC                            |
| mealie.env          | object | `{}`                              | Mealie configuration environment variables |
| mealie.secrets      | object | `{}`                              | Mealie sensitive configuration (secrets)   |
| updateStrategy.type | string | `"RollingUpdate"`                 | StatefulSet update strategy                |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

## Artifact Hub

This chart is prepared for Artifact Hub.

```yaml
annotations:
  artifacthub.io/images: |
    - name: mealie
      image: ghcr.io/mealie-recipes/mealie:v3.9.2
```
