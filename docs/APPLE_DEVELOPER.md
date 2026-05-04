# Apple Developer setup (Easymode)

You cannot create App IDs from this repo; use [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list). These notes exist to reduce copy-paste errors and match what Xcode expects.

## 1. Copy exact bundle IDs from the project

From the repo root:

```bash
chmod +x scripts/list-apple-bundle-ids.sh   # once
./scripts/list-apple-bundle-ids.sh
```

You should see **seven** bundle IDs (main app, tests, UI tests, four extensions including Live Activity) plus team ID `Z4483T87CP`.

## 2. Recommended order in the Developer Portal

1. **Identifiers → App Groups** — Ensure `group.com.easymode.shared` exists (same string as in every `.entitlements` file).
2. **Identifiers → App IDs** — Register **each** bundle ID from the script output as its own identifier (type App / App + extensions use separate IDs).
3. For **every** ID that ships code (not required for local simulator-only work, but required for device and distribution), enable the capabilities that match the tables below, then **Save**.

## 3. Capabilities by bundle ID (mirror Xcode entitlements)

| Bundle ID suffix | Family Controls | App Groups (`group.com.easymode.shared`) |
| --- | --- | --- |
| `name.erikkernan.easymode` (main app) | Yes | Yes |
| `…easymode.tests` | As needed for signing; usually minimal | Optional |
| `…easymode.uitests` | As needed for signing | Optional |
| `…DeviceActivityMonitorExtension` | Yes | Yes |
| `…ShieldConfigurationExtension` | Yes | Yes |
| `…ShieldActionExtension` | Yes | Yes |
| `…EasyModeLiveActivity` | No | Yes |

If a capability is missing on an identifier, **automatic signing in Xcode** often fails with a vague signing error; fix the App ID in the portal, then in Xcode: **Product → Clean Build Folder**, select the **Easymode** target → **Signing & Capabilities** → confirm the correct team and let Xcode refresh.

## 4. After the portal matches Xcode

- Open `easy-mode.xcodeproj`, select each target, **Signing & Capabilities**, same team (`Z4483T87CP`), **Automatically manage signing** (already set in the project).
- Device: unplug/replug once if profiles were just created.
- **Family Controls** may require additional Apple review for App Store distribution; TestFlight/internal builds still need the entitlement enabled on the identifiers.

## 5. Migrating from the old `EasyModeTest1` bundle ID

Treat `name.erikkernan.easymode` as a **new** app on devices and in App Store Connect. You can retire or delete the old App IDs when you no longer need builds signed with them.
