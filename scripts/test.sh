#!/usr/bin/env bash

set -euo pipefail

PROJECT="EasyModeTest1.xcodeproj"
APP_SCHEME="EasyModeTest1"
UNIT_SCHEME="EasyModeTest1-UnitTests"
UI_SCHEME="EasyModeTest1-UITests"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-.build/xcode-derived-data}"

usage() {
  cat <<'EOF'
Usage: scripts/test.sh <command>

Commands:
  build     Build the app for the selected simulator
  unit      Build and run the unit/service test lane
  ui        Build and run the lean UI regression lane
  ui-restore Run the active-session relaunch regression lane
  all       Run unit then UI lanes
  perf-ui   Run the opt-in UI performance lane

Simulator-built apps retain PlugIns/*.appex so ExtensionConfigurationTests see embedded extensions.
Code coverage result bundles are written next to Derived Data (-enableCodeCoverage YES).
EOF
}

resolve_simulator() {
  python3 - <<'PY'
import json
import subprocess
import sys

result = subprocess.run(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    capture_output=True,
    text=True,
    check=True,
)
devices = json.loads(result.stdout).get("devices", {})
preferred_names = [
    "iPhone 17 Pro",
    "iPhone 17",
    "iPhone 16 Pro",
    "iPhone 16",
    "iPhone 16e",
    "iPhone SE (3rd generation)",
]

def runtime_key(runtime_name: str):
    version = runtime_name.split()[-1].replace("-", ".")
    return tuple(int(part) for part in version.split(".") if part.isdigit())

def name_preference(device_name: str):
    try:
        return len(preferred_names) - preferred_names.index(device_name)
    except ValueError:
        return 0

iphone_devices = []
for runtime, runtime_devices in devices.items():
    for device in runtime_devices:
        if not device.get("isAvailable"):
            continue
        name = device.get("name", "")
        if not name.startswith("iPhone"):
            continue
        iphone_devices.append(
            {
                "name": name,
                "udid": device.get("udid", ""),
                "state": device.get("state", "Shutdown"),
                "runtime": runtime,
                "runtime_key": runtime_key(runtime),
                "name_preference": name_preference(name),
            }
        )

booted = [device for device in iphone_devices if device["state"] == "Booted"]
if booted:
    chosen = max(
        booted,
        key=lambda device: (device["runtime_key"], device["name_preference"], device["name"]),
    )
elif iphone_devices:
    chosen = max(
        iphone_devices,
        key=lambda device: (device["runtime_key"], device["name_preference"], device["name"]),
    )
else:
    sys.exit(1)

print(f"{chosen['name']}|{chosen['udid']}")
PY
}

selected_simulator="$(resolve_simulator || true)"
if [[ -z "${selected_simulator}" ]]; then
  echo "No available iPhone simulator was found. Install an iPhone simulator in Xcode and retry." >&2
  exit 1
fi

SIMULATOR_NAME="${selected_simulator%%|*}"
SIMULATOR_UDID="${selected_simulator##*|}"
DESTINATION="platform=iOS Simulator,id=${SIMULATOR_UDID}"

echo "Using simulator: ${SIMULATOR_NAME} (${SIMULATOR_UDID})"

build_lane() {
  local scheme="$1"
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${scheme}" \
    -destination "${DESTINATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    build-for-testing
}

test_lane() {
  local scheme="$1"
  local result_basename="$2"
  shift 2
  local result_path="${DERIVED_DATA_PATH}/${result_basename}.xcresult"
  rm -rf "${result_path}"
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${scheme}" \
    -destination "${DESTINATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    test-without-building \
    -enableCodeCoverage YES \
    -resultBundlePath "${result_path}" \
    "$@"
}

run_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${APP_SCHEME}" \
    -destination "${DESTINATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    build
}

run_unit() {
  build_lane "${UNIT_SCHEME}"
  test_lane "${UNIT_SCHEME}" "unit-tests" \
    -parallel-testing-enabled NO
}

run_ui() {
  build_lane "${UI_SCHEME}"
  test_lane "${UI_SCHEME}" "ui-tests" \
    -only-testing:EasyModeTest1UITests/EasyModeTest1UITests/testOnboardingToFirstTaskCompletion
}

run_ui_restore() {
  build_lane "${UI_SCHEME}"
  test_lane "${UI_SCHEME}" "ui-restore-tests" \
    -only-testing:EasyModeTest1UITests/EasyModeTest1UITests/testActiveSessionRestoresOnRelaunch
}

run_perf_ui() {
  build_lane "${UI_SCHEME}"
  test_lane "${UI_SCHEME}" "ui-perf-tests" \
    -only-testing:EasyModeTest1UITests/EasyModeTest1UITestsLaunchPerformanceTests
}

case "${1:-}" in
  build)
    run_build
    ;;
  unit)
    run_unit
    ;;
  ui)
    run_ui
    ;;
  ui-restore)
    run_ui_restore
    ;;
  all)
    run_unit
    run_ui
    ;;
  perf-ui)
    run_perf_ui
    ;;
  *)
    usage
    exit 1
    ;;
esac
