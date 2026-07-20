#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SCHEME="${SCHEME:-AnchorBuildWeek}"
DEVICE_NAME="${DEVICE_NAME:-iPhone 17e}"
DEVICE_OS="${DEVICE_OS:-26.5}"
BUNDLE_ID="${BUNDLE_ID:-com.Ryunosuke.AnchorBuildWeek}"
DERIVED_DATA="${DERIVED_DATA:-/private/tmp/anchor-buildweek-derived-data}"
CLONED_PACKAGES="${CLONED_PACKAGES:-/private/tmp/anchor-cloned-packages}"
MODULE_CACHE="${MODULE_CACHE:-/private/tmp/anchor-module-cache}"
SWIFTPM_CACHE="${SWIFTPM_CACHE:-/private/tmp/anchor-swiftpm-cache}"
SCREENSHOT_PATH="${SCREENSHOT_PATH:-$ROOT_DIR/anchor-simulator-check.png}"
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$ROOT_DIR/StoreScreenshots}"

usage() {
  cat <<USAGE
Usage: Scripts/anchor_simulator_loop.sh <command>

Commands:
  list          Show schemes and available simulator destinations.
  build         Build Anchor for the configured iOS Simulator.
  boot          Boot the configured simulator.
  install       Install the latest simulator build.
  launch        Launch Anchor in the configured simulator.
  screenshot    Capture a simulator screenshot.
  store-shot     Capture a named App Store screenshot. Usage: store-shot <name>
  smoke         Build, boot, install, launch, and capture a screenshot.

Environment overrides:
  SCHEME=$SCHEME
  DEVICE_NAME=$DEVICE_NAME
  DEVICE_OS=$DEVICE_OS
  BUNDLE_ID=$BUNDLE_ID
  DERIVED_DATA=$DERIVED_DATA
  CLONED_PACKAGES=$CLONED_PACKAGES
  MODULE_CACHE=$MODULE_CACHE
  SWIFTPM_CACHE=$SWIFTPM_CACHE
  SCREENSHOT_PATH=$SCREENSHOT_PATH
  SCREENSHOT_DIR=$SCREENSHOT_DIR
USAGE
}

section() {
  printf '\n== %s ==\n' "$1"
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'ERROR: Missing required tool: %s\n' "$1" >&2
    exit 1
  }
}

destination() {
  printf 'platform=iOS Simulator,name=%s,OS=%s' "$DEVICE_NAME" "$DEVICE_OS"
}

sim_udid() {
  xcrun simctl list devices available \
    | awk -v name="$DEVICE_NAME" -v os="$DEVICE_OS" '
      $0 ~ "-- iOS " os " --" { in_os = 1; next }
      /^-- / { in_os = 0 }
      in_os && index($0, name " (") {
        line = $0
        sub(/^[^(]*\(/, "", line)
        sub(/\).*/, "", line)
        if (line != "") {
          print line
          exit
        }
      }
    '
}

app_path() {
  printf '%s/Build/Products/Debug-iphonesimulator/Anchor Build Week.app' "$DERIVED_DATA"
}

build_app() {
  section "Build"
  mkdir -p "$DERIVED_DATA" "$CLONED_PACKAGES" "$MODULE_CACHE" "$SWIFTPM_CACHE"
  CLANG_MODULE_CACHE_PATH="$MODULE_CACHE" \
  SWIFTPM_CACHE_PATH="$SWIFTPM_CACHE" \
    xcodebuild \
    -scheme "$SCHEME" \
    -destination "$(destination)" \
    -derivedDataPath "$DERIVED_DATA" \
    -clonedSourcePackagesDirPath "$CLONED_PACKAGES" \
    build
}

boot_sim() {
  section "Boot Simulator"
  local udid
  udid="$(sim_udid)"
  [[ -n "$udid" ]] || {
    printf 'ERROR: Simulator not found: %s / iOS %s\n' "$DEVICE_NAME" "$DEVICE_OS" >&2
    exit 1
  }
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b
  printf 'Simulator UDID: %s\n' "$udid"
}

install_app() {
  section "Install"
  local udid path
  udid="$(sim_udid)"
  path="$(app_path)"
  [[ -d "$path" ]] || {
    printf 'ERROR: App build not found: %s\n' "$path" >&2
    exit 1
  }
  xcrun simctl install "$udid" "$path"
}

launch_app() {
  section "Launch"
  local udid
  udid="$(sim_udid)"
  xcrun simctl launch "$udid" "$BUNDLE_ID"
}

capture_screenshot() {
  section "Screenshot"
  local udid
  udid="$(sim_udid)"
  xcrun simctl io "$udid" screenshot "$SCREENSHOT_PATH"
  printf 'Screenshot: %s\n' "$SCREENSHOT_PATH"
}

capture_store_screenshot() {
  section "Store Screenshot"
  local udid name path
  udid="$(sim_udid)"
  name="${1:-screen}"
  name="$(printf '%s' "$name" | tr -cs '[:alnum:]_-' '-' | sed 's/^-//; s/-$//')"
  [[ -n "$name" ]] || name="screen"
  mkdir -p "$SCREENSHOT_DIR"
  path="$SCREENSHOT_DIR/$(date +%Y%m%d-%H%M%S)-$name.png"
  xcrun simctl io "$udid" screenshot "$path"
  printf 'Store screenshot: %s\n' "$path"
}

list_setup() {
  section "Schemes"
  xcodebuild -list
  section "Destinations"
  xcodebuild -scheme "$SCHEME" -showdestinations
}

main() {
  require_tool xcodebuild
  require_tool xcrun
  require_tool awk

  case "${1:-}" in
    list)
      list_setup
      ;;
    build)
      build_app
      ;;
    boot)
      boot_sim
      ;;
    install)
      install_app
      ;;
    launch)
      launch_app
      ;;
    screenshot)
      capture_screenshot
      ;;
    store-shot)
      capture_store_screenshot "${2:-screen}"
      ;;
    smoke)
      build_app
      boot_sim
      install_app
      launch_app
      sleep 2
      capture_screenshot
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      printf 'ERROR: Unknown command: %s\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
