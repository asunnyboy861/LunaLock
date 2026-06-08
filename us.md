# LunaLock - iOS Development Guide

## Executive Summary

LunaLock is a privacy-first period tracking app for iOS that stores 100% of data locally on-device with zero cloud, zero accounts, and zero tracking. Unlike Flo, Clue, and Ovia — which require accounts, collect user data, and force ovulation/fertility features — LunaLock is designed for women who want pure period tracking without compromise.

**Core Differentiators**:
- **Zero cloud, zero accounts** — All data stored locally with SQLCipher AES-256 encryption
- **No ovulation/fertility/pregnancy features** — Pure period tracking only
- **One-time purchase** — $3.99 forever, no subscription (aligns with privacy promise)
- **Post-Roe legal safety** — Data never leaves device, cannot be subpoenaed
- **Emergency lock** — Shake-to-lock for instant protection

**Target Market**: US women aged 18-40 who prioritize privacy, childfree users, post-Roe privacy-concerned users, and LGBTQ+ inclusive design seekers.

**App Category**: Health & Fitness / Medical

## Competitive Analysis

| App | Strengths | Weaknesses | LunaLock Advantage |
|-----|-----------|------------|-------------------|
| **Flo** | Most popular, AI predictions, rich content | $49.99/yr subscription, FTC fined $59.5M for data sharing, requires account, forced ovulation/fertility | Zero data collection, no subscription, no ovulation features |
| **Clue** | Scientific approach, GDPR compliant, not pink | $39.99/yr subscription, requires account, server-side data, forced ovulation/fertility | 100% local, no account needed, one-time purchase |
| **Ovia** | Pregnancy tracking, community | Requires pregnancy status input, data shared with employers, forced fertility | No fertility/pregnance features at all |
| **Euki** | Privacy-first, local storage, open source | Outdated UI, no predictions, limited features, poor design | Modern SwiftUI design, cycle prediction, encrypted storage |
| **Apple Health** | Built-in, free, privacy-focused | Forced ovulation/fertility display, limited customization | No ovulation display, dedicated UX, encrypted DB |

## Feature Inventory

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | **Period Logging** | 1. User opens app → 2. Taps "Log Period" button on Dashboard → 3. System records start date with haptic feedback | Start date (default: today), flow level (1-4) | CyclePredictor calculates cycle length from previous records; DataStore saves to CoreData | Updated countdown, cycle day indicator, phase badge | CoreData CycleRecord entity (encrypted via SQLCipher) | Period appears in calendar, countdown updates, haptic feedback fires |
| 2 | **Period End Logging** | 1. User taps "End Period" → 2. System calculates period length → 3. Updates record | End date (default: today) | Calculate period length (days between start and end) | Updated cycle record with period length | CoreData CycleRecord.endDate, periodLength | Period length displayed in record, calendar shows correct range |
| 3 | **Cycle Prediction** | 1. System auto-calculates after ≥2 cycles → 2. Displays next period date with confidence range | Historical cycle start dates | Weighted average of last 6 cycle lengths, std dev calculation, confidence interval | Days until next period, predicted date, +/- confidence range | In-memory from CycleRecord data | Prediction shown on dashboard with confidence range, updates with each new cycle |
| 4 | **Symptom Tracking** | 1. User taps "Log Symptoms" → 2. Selects from symptom grid → 3. Auto-saves on selection | Symptom selections (cramps, bloating, headache, fatigue, acne, mood swings + custom Pro) | Map symptoms to date, validate enum values | Symptom badges on calendar, symptom history list | CoreData SymptomEntry entity (encrypted) | Symptoms appear on calendar date, auto-save with haptic feedback |
| 5 | **Mood Tracking** | 1. User taps mood icon in Quick Log → 2. Selects mood level → 3. Auto-saves | Mood selection (happy, calm, anxious, sad, irritable, energetic) | Map mood to date | Mood indicators on calendar, mood patterns in trends | CoreData MoodEntry entity (encrypted) | Mood appears on calendar, included in trend analysis |
| 6 | **Flow Level Tracking** | 1. User selects flow level during period logging → 2. Auto-saves | Flow level: Spotting/Light/Medium/Heavy | Map flow to date | Flow indicators on calendar | CoreData FlowRecord (part of CycleRecord) | Flow level shown on calendar, included in trend charts |
| 7 | **Calendar View** | 1. User taps Calendar tab → 2. Views month with period/prediction markers → 3. Taps date to see details | Month navigation (swipe/tap arrows), date selection | Load records for visible month, calculate phase for each day | Color-coded calendar: red=period, purple=predicted, green=follicular, orange=luteal | Read from CoreData | Calendar shows all period days, predictions, and phase colors correctly |
| 8 | **FaceID/PIN Lock** | 1. User enables in Settings → 2. App requires auth on launch → 3. FaceID auto or PIN entry | FaceID biometric or 4-6 digit PIN | LocalAuthentication framework for FaceID; Keychain for PIN storage | Lock screen overlay or direct access | Keychain (PIN), LAContext (FaceID) | App locked on launch, FaceID works instantly, PIN fallback available |
| 9 | **Emergency Lock (Shake)** | 1. User shakes device → 2. App instantly locks → 3. Requires FaceID/PIN to unlock | Device motion (shake gesture) | MotionManager detects shake pattern | Lock screen overlay | SecurityManager.isLocked state | Shake triggers instant lock, no data visible, requires auth to unlock |
| 10 | **Auto-Lock Timer** | 1. User configures in Settings → 2. App locks after specified time in background | Timer selection: Immediate / 30s / 1min / 5min | Background timer tracking | Lock screen on next foreground | UserDefaults autoLockInterval | App locks after configured time in background |
| 11 | **Trend Charts (Pro)** | 1. User taps Trends tab → 2. Views cycle length / symptom / mood charts → 3. Swipes between chart types | Date range selection | Aggregate CoreData records, calculate averages and patterns | Line/bar charts with cycle length trends, symptom frequency, mood patterns | Read from CoreData (computed) | Charts display accurate data, smooth animations, correct date ranges |
| 12 | **Data Export (Pro)** | 1. User goes to Settings → Export → 2. Selects format (PDF/JSON) → 3. Shares via system sheet | Format selection (PDF or JSON) | Generate PDF with cycle summary / JSON with all records | Share sheet with file attachment | Read from CoreData, generate file | PDF opens correctly, JSON is valid, share sheet works |
| 13 | **Widget (Pro)** | 1. User adds LunaLock widget to home screen → 2. Widget shows countdown | Widget configuration | Read latest prediction from shared UserDefaults | Days until next period, cycle day, phase indicator | Shared UserDefaults / App Group | Widget updates daily, shows correct countdown, taps open app |
| 14 | **Period Reminders** | 1. User enables in Settings → 2. System sends local notification before predicted period | Days before notification (1-3 days) | Schedule UNUserNotification based on prediction | Local push notification | UNUserNotificationCenter | Notification fires at correct time, tapping opens app |
| 15 | **Onboarding / Privacy Promise** | 1. First launch → 2. Privacy promise screen → 3. Quick setup (last period date) | Last period date (optional) | Store onboarding completion flag | Privacy promise displayed, setup complete | UserDefaults isOnboarded | Onboarding shows once, privacy promise visible, can skip date entry |
| 16 | **Data Deletion** | 1. Settings → Delete All Data → 2. Confirmation dialog → 3. All data permanently deleted | Confirmation tap | NSBatchDeleteRequest on all entities | Empty app state, back to onboarding | CoreData batch delete | All records removed, no recoverable data, app resets to onboarding |
| 17 | **Theme Customization (Pro)** | 1. Settings → Theme → 2. Select from 5 color schemes → 3. Instant preview | Theme selection | Update accent color across app | Updated UI colors throughout app | UserDefaults selectedTheme | Theme changes instantly, persists across launches, all views update |
| 18 | **HealthKit Write-Only (Pro)** | 1. Settings → HealthKit → 2. Enable → 3. Grant permission → 4. Period data written to Health | HealthKit authorization | Write menstrual data to HKHealthStore (menstrual flow, cycle start) | Data appears in Apple Health app | HKHealthStore (write only) | Data written to Health, app NEVER reads from Health |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Period Logging | Quick Log Button | One-tap period start from dashboard | Tap button |
| 1.2 | Period Logging | Flow Level Selector | Select flow intensity during logging | Tap segmented control |
| 4.1 | Symptom Tracking | Preset Symptoms | 6 preset symptoms: cramps, bloating, headache, fatigue, acne, mood swings | Tap grid icons |
| 4.2 | Symptom Tracking | Custom Symptoms (Pro) | Add unlimited custom symptom names | Tap + button, type name |
| 7.1 | Calendar View | Date Detail Sheet | Tap date to see symptoms, mood, flow for that day | Tap date cell |
| 7.2 | Calendar View | Month Navigation | Swipe left/right or tap arrows to change month | Swipe / tap |
| 8.1 | FaceID/PIN Lock | Lock Icon | Visible lock icon in top-right of dashboard indicating security status | Visual indicator |
| 11.1 | Trend Charts | Cycle Length Chart | Line chart showing cycle length over time | Swipe between charts |
| 11.2 | Trend Charts | Symptom Frequency | Bar chart of most common symptoms | Swipe between charts |
| 11.3 | Trend Charts | Mood Patterns | Chart showing mood distribution across cycle | Swipe between charts |
| 13.1 | Widget | Small Widget | Days until next period + phase badge | Home screen |
| 13.2 | Widget | Medium Widget | Countdown + cycle day + next period date | Home screen |
| 15.1 | Onboarding | Privacy Promise | Full-screen privacy commitment with lock animation | Swipe to continue |
| 15.2 | Onboarding | Last Period Input | Optional date picker for last period start | Date picker + tap confirm |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Period log updates prediction | Period Logging | Cycle Prediction | New start date | User logs period |
| Prediction updates countdown | Cycle Prediction | Dashboard | Days until, confidence | After prediction recalculation |
| Prediction updates calendar | Cycle Prediction | Calendar View | Predicted dates | After prediction recalculation |
| Prediction updates widget | Cycle Prediction | Widget | Days until, cycle day | After prediction recalculation |
| Prediction triggers reminder | Cycle Prediction | Period Reminders | Predicted date | After prediction recalculation |
| Symptoms appear on calendar | Symptom Tracking | Calendar View | Symptom entries for date | User logs symptoms |
| Mood appears on calendar | Mood Tracking | Calendar View | Mood entries for date | User logs mood |
| Symptoms feed trends | Symptom Tracking | Trend Charts | Aggregated symptom data | User opens Trends tab |
| Mood feeds trends | Mood Tracking | Trend Charts | Aggregated mood data | User opens Trends tab |
| Pro check gates features | IAP Purchase | Trend Charts, Export, Widget, Theme, HealthKit, Custom Symptoms | isPro boolean | User attempts Pro feature |
| Emergency lock triggers auth | Emergency Lock | FaceID/PIN Lock | isLocked = true | Shake detected |
| Period data writes to Health | Period Logging | HealthKit Write | Menstrual flow data | User enables HealthKit + logs period |
| Delete all resets everything | Data Deletion | All features | Empty state | User confirms deletion |

## Apple Design Guidelines Compliance

- **HIG Privacy**: App collects zero data; Privacy Nutrition Label will show "No Data Collected"
- **HIG Health Apps**: App does not provide medical advice; clear disclaimer in onboarding
- **HIG Local Authentication**: FaceID/PIN implemented per LAContext guidelines with fallback
- **HIG Data Protection**: NSPersistentStoreFileProtectionKey set to complete protection
- **HIG Notifications**: Local notifications only, user-controlled, no remote push
- **HIG Accessibility**: VoiceOver labels on all interactive elements, Dynamic Type support
- **HIG Dark Mode**: Full Light/Dark mode support with semantic colors
- **HIG Haptics**: UIImpactFeedbackGenerator for key actions (log period, save symptom)
- **HIG Navigation**: Tab-based navigation with 4 tabs (Home, Calendar, Trends, Settings)
- **App Store Review Guideline 5.1.1**: Health data stored only on-device, no collection/sharing
- **App Store Review Guideline 2.1**: App fully functional without account or network

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (LocalAuthentication)
- **Data**: CoreData with SQLCipher encryption, Keychain for security credentials
- **Notifications**: UNUserNotificationCenter (local only)
- **Widgets**: WidgetKit (static configuration)
- **Health**: HealthKit (write-only, optional)
- **IAP**: StoreKit 2 (non-consumable one-time purchase)
- **Charts**: Swift Charts framework
- **Security**: LocalAuthentication (FaceID/TouchID), Keychain Services
- **No third-party SDKs**: Zero analytics, zero tracking, zero ad frameworks

## Module Structure

```
LunaLock/
├── LunaLockApp.swift                    // App entry + security gate
├── Models/
│   ├── CycleRecord.swift                // Period record entity
│   ├── SymptomEntry.swift               // Symptom record entity
│   ├── MoodEntry.swift                  // Mood record entity
│   └── CyclePrediction.swift            // Prediction result model
├── ViewModels/
│   ├── DashboardViewModel.swift         // Dashboard state & logic
│   ├── CalendarViewModel.swift          // Calendar state & logic
│   ├── TrendViewModel.swift             // Trends state & logic
│   └── SettingsViewModel.swift          // Settings state & logic
├── Views/
│   ├── Onboarding/
│   │   ├── PrivacyPromiseView.swift     // Privacy promise screen
│   │   └── LastPeriodInputView.swift    // Quick setup
│   ├── Dashboard/
│   │   ├── DashboardView.swift          // Main dashboard
│   │   ├── CountdownCard.swift          // Days until next period
│   │   ├── QuickActionsView.swift       // Log Period / Log Symptoms
│   │   └── PhaseBadge.swift             // Cycle phase indicator
│   ├── Calendar/
│   │   ├── CalendarView.swift           // Monthly calendar
│   │   └── DateDetailView.swift         // Day detail sheet
│   ├── Symptoms/
│   │   ├── QuickLogView.swift           // Symptom + mood quick log
│   │   └── SymptomGridView.swift        // Symptom selection grid
│   ├── Trends/
│   │   └── TrendChartView.swift         // Charts (Pro)
│   ├── Settings/
│   │   ├── SettingsView.swift           // Settings main
│   │   ├── SecuritySettingsView.swift   // FaceID/PIN/Auto-lock
│   │   ├── ExportView.swift             // Data export (Pro)
│   │   └── ThemePickerView.swift        // Theme selection (Pro)
│   ├── Lock/
│   │   └── LockScreenView.swift         // FaceID/PIN lock screen
│   └── Paywall/
│       └── PaywallView.swift            // Pro upgrade screen
├── Services/
│   ├── DataStore.swift                  // CoreData manager + CRUD
│   ├── CyclePredictor.swift             // Prediction algorithm
│   ├── SecurityManager.swift            // FaceID/PIN/Auto-lock
│   ├── NotificationManager.swift        // Local notifications
│   ├── ExportManager.swift              // PDF/JSON export
│   ├── HapticManager.swift              // Haptic feedback
│   ├── ThemeManager.swift               // Theme management
│   └── StoreManager.swift              // StoreKit 2 IAP
├── Helpers/
│   ├── Constants.swift                  // App constants & config
│   └── DateExtensions.swift             // Date helper extensions
├── Widget/
│   ├── LunaLockWidget.swift             // Widget entry point
│   └── LunaLockWidgetBundle.swift       // Widget bundle
└── Resources/
    ├── Assets.xcassets                  // Icons & colors
    ├── LunaLock.xcdatamodeld            // CoreData model
    └── Localizable.strings              // Localization
```

## Data Flow Diagram

### Feature: Period Logging
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Log Period" → optional flow level selection     │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── DashboardViewModel.logPeriod()                       │
│      → DataStore.logPeriodStart(date, flowLevel)          │
│      → CyclePredictor.predict(from: records)              │
│      → HapticManager.successFeedback()                    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CoreData CycleRecord (startDate, flowLevel)          │
│      → SQLCipher AES-256 encrypted store                  │
│      → Update previous record's cycleLength               │
│       │                                                   │
│  Display Output                                           │
│  └── Dashboard: updated countdown, phase badge, cycle day │
│  └── Calendar: red markers on period dates                │
│  └── Widget: updated countdown (if Pro)                   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── NotificationManager: reschedule reminders            │
│  └── HealthKit: write menstrual data (if Pro + enabled)   │
└───────────────────────────────────────────────────────────┘
```

### Feature: Symptom Tracking
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap symptom icons in QuickLogView → auto-save        │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── QuickLogView: on tap → DataStore.logSymptom()        │
│      → HapticManager.lightFeedback()                      │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CoreData SymptomEntry (date, symptomType, note)      │
│      → SQLCipher encrypted                                │
│       │                                                   │
│  Display Output                                           │
│  └── Calendar: symptom badge on date cell                 │
│  └── Trends: symptom frequency chart (Pro)                │
└───────────────────────────────────────────────────────────┘
```

### Feature: Cycle Prediction
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── (Automatic — triggered by period logging)            │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CyclePredictor.predict(from: [CycleRecord])          │
│      → Calculate intervals between consecutive starts     │
│      → Weighted average (last 6 cycles, recent weighted)  │
│      → Standard deviation → confidence range (+/- days)   │
│      → NEVER calculate ovulation or fertility             │
│       │                                                   │
│  Model/Persistence                                        │
│  └── In-memory CyclePrediction struct                     │
│      → Cached until next period logged                    │
│       │                                                   │
│  Display Output                                           │
│  └── Dashboard: "12 days away" countdown + "+/- 2 days"   │
│  └── Calendar: purple markers on predicted dates          │
│  └── Widget: countdown display (Pro)                      │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── NotificationManager: schedule reminder 1-3 days      │
│      before predicted start                               │
└───────────────────────────────────────────────────────────┘
```

### Feature: Security (FaceID/PIN/Emergency Lock)
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── App launch → FaceID scan / PIN entry / shake gesture │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SecurityManager.authenticate()                       │
│      → LAContext.evaluatePolicy(.deviceOwnerAuthentication)│
│      → Or: compare PIN with Keychain-stored PIN           │
│      → Or: MotionManager shake detection → emergencyLock() │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Keychain: PIN storage (kSecClassGenericPassword)     │
│  └── UserDefaults: lock method preference, auto-lock time │
│       │                                                   │
│  Display Output                                           │
│  └── LockScreenView: FaceID prompt / PIN pad / locked     │
│  └── Dashboard: lock icon indicator                       │
└───────────────────────────────────────────────────────────┘
```

### Feature: Data Export (Pro)
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Settings → Export → Select PDF or JSON               │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── ExportManager.exportAsPDF() / .exportAsJSON()        │
│      → Fetch all CycleRecord + SymptomEntry + MoodEntry   │
│      → PDF: formatted cycle summary with charts           │
│      → JSON: structured data dump                         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Read from CoreData (all entities)                    │
│  └── Generate temporary file in app tmp directory         │
│       │                                                   │
│  Display Output                                           │
│  └── UIActivityViewController share sheet                 │
│      → Save to Files, AirDrop, Mail, etc.                 │
└───────────────────────────────────────────────────────────┘
```

## Implementation Flow

1. Create Xcode project with SwiftUI, configure bundle ID `com.zzoutuo.LunaLock`, iOS 17.0+
2. Define CoreData model (CycleRecord, SymptomEntry, MoodEntry entities)
3. Implement DataStore with CoreData + SQLCipher encryption
4. Implement SecurityManager (FaceID/PIN/Auto-lock/Emergency lock)
5. Implement CyclePredictor algorithm (weighted average, confidence range)
6. Build Dashboard view (countdown, quick actions, phase indicator)
7. Build Calendar view (month grid, period/prediction markers, date detail)
8. Build Symptom Quick Log view (grid selection, auto-save)
9. Build Settings view (security, export, theme, HealthKit, about)
10. Implement LockScreen view (FaceID/PIN authentication gate)
11. Implement Onboarding (Privacy Promise, last period input)
12. Implement StoreKit 2 IAP (non-consumable Pro upgrade)
13. Implement Paywall view (Pro feature list, purchase button)
14. Build Trend Charts (Pro) using Swift Charts
15. Build Export Manager (PDF/JSON generation)
16. Build Widget using WidgetKit (Pro)
17. Implement NotificationManager (period reminders)
18. Implement ThemeManager (5 color schemes)
19. Implement HealthKit write-only integration (Pro)
20. UI polish, animations, haptic feedback, accessibility
21. TestFlight testing and App Store submission

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary Accent: #7C4DFF (deep purple — mysterious, powerful, non-stereotypical)
  - Period Red: #FF6B6B
  - Calm Green: #4ECDC4
  - Alert Yellow: #FFE66D
  - Comfort Green: #A8E6CF
  - Light Background: #FAFAFA
  - Dark Background: #1A1A2E
  - Light Text: #2D2D2D
  - Dark Text: #E8E8E8
- **Typography**: SF Pro Rounded for countdown numbers (72pt+), SF Pro Text for body
- **Layout**: 4-tab navigation (Home, Calendar, Trends, Settings), max 3 primary actions per screen
- **Animations**: Subtle spring animations on card transitions, haptic feedback on all key actions
- **Dark Mode**: Default theme, full semantic color support
- **Accessibility**: VoiceOver labels, Dynamic Type, minimum 44pt touch targets
- **Gender-Inclusive Language**: Use "period" not "menstruation", no gendered assumptions
- **Privacy Visibility**: Lock icon always visible in navigation bar, encryption badge in settings

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: SwiftUI, Swift Charts, WidgetKit, StoreKit 2
- NEVER include ovulation, fertility, or pregnancy code or UI — this is a hard rule
- All data storage must be encrypted (SQLCipher AES-256)
- Zero network requests — no URLSession, no Firebase, no Analytics
- Auto-save on selection — no "Save" buttons for symptoms/mood
- Haptic feedback on key actions
- Gender-inclusive language throughout
- Dark mode support mandatory
- VoiceOver and Dynamic Type support mandatory
- Minimum iOS 17.0
- MVVM architecture pattern

## Build & Deployment Checklist

- [ ] Xcode project configured with bundle ID com.zzoutuo.LunaLock
- [ ] CoreData model with CycleRecord, SymptomEntry, MoodEntry
- [ ] SQLCipher encryption integrated
- [ ] FaceID/PIN lock implemented with LocalAuthentication
- [ ] Emergency shake-to-lock implemented
- [ ] Period one-tap logging with haptic feedback
- [ ] Symptom auto-save selection
- [ ] Cycle prediction algorithm (weighted average, no ovulation)
- [ ] Calendar view with period/prediction markers
- [ ] Trend charts (Pro) with Swift Charts
- [ ] Widget (Pro) with WidgetKit
- [ ] Data export PDF/JSON (Pro)
- [ ] StoreKit 2 non-consumable IAP
- [ ] HealthKit write-only integration (Pro)
- [ ] Theme customization (Pro)
- [ ] Local notification reminders
- [ ] Onboarding with privacy promise
- [ ] Data deletion (complete, no recovery)
- [ ] App Store metadata with ASO optimization
- [ ] Privacy Nutrition Label: "No Data Collected"
- [ ] TestFlight beta testing
- [ ] App Store submission
