# Helm Chart Releases

This repository includes automated release workflow for publishing the Alfalfa Helm chart when GitHub releases are created.

## Release Workflow

**Trigger:** When a GitHub release is published

**Actions:**
1. **Package Chart**: Builds dependencies and packages the `alfalfa-chart`
2. **Release Assets**: Uploads chart package (.tgz file) to the GitHub release
3. **OCI Registry**: Pushes chart to GitHub Container Registry for OCI-based installation
4. **Helm Repository**: Updates and publishes Helm repository index to GitHub Pages

## Using the Chart

### From GitHub Releases
Download chart package directly:
```bash
# Download latest release package
curl -LO https://github.com/NREL/alfalfa-helm/releases/latest/download/alfalfa-<version>.tgz

# Install locally
helm install alfalfa ./alfalfa-<version>.tgz
```

### From Helm Repository
Add as a Helm repository (requires GitHub Pages to be enabled):
```bash
helm repo add alfalfa https://nrel.github.io/alfalfa-helm
helm repo update
helm install alfalfa alfalfa/alfalfa
```

### From OCI Registry
Use OCI-based installation:
```bash
helm install alfalfa oci://ghcr.io/nrel/helm-charts/alfalfa
```

## Creating a Release

1. **Prepare chart**: Ensure the chart is ready and version is updated in `alfalfa-chart/Chart.yaml`
2. **Create release**: Use GitHub's interface or CLI:
   ```bash
   # Using GitHub CLI
   gh release create v1.2.3 --title "Release v1.2.3" --notes "Release notes here"
   ```
3. **Automatic processing**: The release workflow will handle packaging and publishing
2. **Create release**: Use GitHub's interface or CLI:
   ```bash
   # Using GitHub CLI
   gh release create v1.2.3 --title "Release v1.2.3" --notes "Release notes here"
   ```
3. **Automatic processing**: The release workflow will handle packaging and publishing

## GitHub Pages Setup

To enable the Helm repository:
1. Go to repository Settings → Pages
2. Set source to "GitHub Actions"
3. After first release, repository will be available at `https://nrel.github.io/alfalfa-helm`

## Requirements

- No additional secrets needed (uses `GITHUB_TOKEN`)
- GitHub Pages should be enabled for Helm repository functionality
- Repository needs `contents: write` and `packages: write` permissions (configured in workflow)
