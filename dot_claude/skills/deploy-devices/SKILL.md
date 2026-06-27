---
name: deploy-devices
description: Use the run-on-devices script to build once and deploy iOS or visionOS apps to all connected physical devices in parallel. Use when the user wants to install/deploy a Swift app to physical iPhones, iPads, or Vision Pro devices from the command line, or asks about run-on-devices.
---

# Multi-Device iOS/visionOS Deployment

Script location: `~/.local/bin/run-on-devices`

Builds an Xcode scheme once and installs the resulting `.app` on every connected physical device in parallel. Handles Apple's non-breaking spaces (U+00A0) in device names like "Apple Vision Pro".

## Usage

```bash
# List all connected physical devices
run-on-devices --list

# Deploy iOS app to all iPhones/iPads
run-on-devices --scheme "MyApp" --bundle-id "com.example.app"

# Deploy visionOS app to all Vision Pro devices
run-on-devices --scheme "MyApp" --bundle-id "com.example.app" --platform visionos

# Skip build, just redeploy the last build
run-on-devices --scheme "MyApp" --bundle-id "com.example.app" --no-build

# Filter to specific devices by name
run-on-devices --scheme "MyApp" --bundle-id "com.example.app" --filter "iPhone 15"
```

## Options

| Option | Description |
|--------|-------------|
| `--scheme NAME` | Xcode scheme to build (required) |
| `--bundle-id ID` | App bundle identifier (required) |
| `--platform PLATFORM` | Target: `ios` or `visionos` (default: ios) |
| `--config CONFIG` | Build configuration (default: Debug) |
| `--project DIR` | Project directory (default: current) |
| `--build-dir DIR` | Build output directory |
| `--app-name NAME` | App name with .app extension (if different from scheme) |
| `--filter PATTERN` | Filter devices by name pattern |
| `--no-build` | Skip build, only deploy |
| `--list` | List available devices and exit |

## Project Examples

```bash
# VisionImpossible (visionOS) — app name differs from scheme
run-on-devices --scheme "VisionImpossible" --bundle-id "dk.visionimpossible.stream" \
  --platform visionos --app-name "VisionImpossible Stream.app"

# CrewCast (iOS)
run-on-devices --scheme "CrewCast" --bundle-id "com.friismobility.koora"
```
