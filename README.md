# Marisme Helm Charts

This repository contains Helm charts maintained by Marisme.

## Repository Layout

```text
charts/
  oxidized/
    Chart.yaml
    values.yaml
    templates/
```

The source branch stores chart source code. The published Helm repository is
served from GitHub Pages and contains packaged charts plus `index.yaml`.

## Charts

| Chart | Description |
| --- | --- |
| `oxidized` | Deploy Oxidized for network device configuration backup |

## Development

Lint all charts:

```bash
helm lint charts/*
```

Render the Oxidized chart locally:

```bash
helm template oxidized charts/oxidized
```

Package charts manually:

```bash
mkdir -p .dist
helm package charts/* -d .dist
helm repo index .dist --url https://marismecom.github.io/charts
```

## Installation

After GitHub Pages is enabled and the release workflow has published the chart:

```bash
helm repo add marisme https://marismecom.github.io/charts
helm repo update
helm install oxidized marisme/oxidized -n oxidized --create-namespace
```

## Artifact Hub

Add this repository in Artifact Hub as a Helm charts repository:

```text
https://marismecom.github.io/charts
```

The `artifacthub-repo.yml` file must be published at the same level as
`index.yaml` in the GitHub Pages branch.
