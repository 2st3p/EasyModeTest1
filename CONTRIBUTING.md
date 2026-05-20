# Contributing

## Prerequisites

- Xcode with an iOS 17.6+ SDK (project deployment target).
- [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) installed locally if you want to match CI.

## Build and tests

From the repository root:

```bash
./scripts/test.sh build   # app build for an available iPhone simulator
./scripts/test.sh unit    # unit tests + code coverage xcresult under .build/xcode-derived-data/
```

See [`AGENTS.md`](./AGENTS.md) for the full test matrix and device install commands.

### Pre-merge checklist

Run on a Mac with full Xcode (not Command Line Tools only):

```bash
# If xcodebuild fails with "requires Xcode", point at the app bundle:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

swiftlint --strict

./scripts/test.sh build
./scripts/test.sh unit
./scripts/test.sh ui
# Or: ./scripts/test.sh all
```

CI runs lint, build, unit tests, and the lean UI regression lane. Re-run `./scripts/test.sh unit` twice locally if you change result-bundle or Derived Data caching behavior.

## Style

- SwiftLint rules: `.swiftlint.yml`
- SwiftFormat config: `.swiftformat`

Run `swiftlint --strict` before pushing; CI runs SwiftLint on pull requests. Optional: `swiftformat .` locally (see `.swiftformat`).

## Brand tokens

Canonical RGB tuples live in [`Shared/BrandRGB.swift`](./Shared/BrandRGB.swift) (compiled into the app, extensions, and Live Activity). [`Shared/BrandTokens.swift`](./Shared/BrandTokens.swift) exposes SwiftUI `Color` helpers for the main app. After changing tokens, run unit tests (`BrandTokensParityTests`).
