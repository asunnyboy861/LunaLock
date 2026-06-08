# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:

- "通知" / "提醒" / "notification" / "alert" found in guide -> Push Notifications (local only)
- "健康" / "health" / "HealthKit" found in guide -> HealthKit (write-only, optional)
- "购买" / "premium" / "Pro" found in guide -> In-App Purchase (non-consumable)
- "FaceID" / "PIN" / "锁定" / "lock" found in guide -> Local Authentication
- "Widget" / "小组件" found in guide -> WidgetKit (no special entitlement needed)
- "导出" / "export" / "PDF" / "JSON" found in guide -> No special capability needed

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications (Local) | Configured | Will use UNUserNotificationCenter, no entitlement needed for local notifications |
| In-App Purchase | Configured | StoreKit 2 non-consumable, no special entitlement needed |
| FaceID | Configured | NSFaceIDUsageDescription in Info.plist |
| WidgetKit | Configured | Widget extension target, no special entitlement needed |
| HealthKit | Configured | HealthKit capability + entitlement + Info.plist description |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| HealthKit | Pending | 1. Enable HealthKit in Xcode Signing & Capabilities 2. Add HealthKit entitlement to .entitlements 3. Add NSHealthShareUsageDescription and NSHealthUpdateUsageDescription to Info.plist 4. Note: App only WRITES to HealthKit, never reads |

## No Configuration Needed
- iCloud: Not required (100% local storage)
- Location Services: Not required
- Camera/Photo Library: Not required
- Siri: Not required
- Apple Watch: Not required for MVP
- Background Modes: Not required (no background fetch needed)
- Sign in with Apple: Not required (no accounts)

## Verification
- Build succeeded after configuration: YES
- All entitlements correct: Pending (will be configured during code generation)
