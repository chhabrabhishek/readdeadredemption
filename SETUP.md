# ReadDeadRedemption - Production Setup Guide

## Architecture Overview

ReadDeadRedemption uses a modular MVVM architecture with SwiftData persistence, Apple Screen Time APIs, and modern Swift concurrency.

### Key Architectural Decisions

1. **MVVM + Services**: Clean separation between Views, ViewModels (via @Observable), and Services
2. **SwiftData**: Modern persistence over CoreData for iOS 18+
3. **App Groups**: Shared data between main app and extensions
4. **@Observable macro**: Modern observation over Combine where possible
5. **Async/await**: Native concurrency throughout

### Apple Screen Time API Constraints & Realities

**Important limitations to understand:**

1. **FamilyControls** requires a special entitlement from Apple (must apply via developer portal)
2. **Shield UI** is extremely limited - you can only customize text and icon, not full custom UI
3. **DeviceActivityMonitor** runs as a separate extension with limited memory (6MB)
4. **ManagedSettings** persists across app restarts automatically
5. Apps are represented as opaque `ApplicationToken` - you cannot get app names/bundle IDs
6. The `FamilyActivityPicker` is the ONLY way to let users select apps
7. Screen Time APIs only work on physical devices, NOT simulators
8. You MUST be part of Apple Developer Program and request the Family Controls entitlement

### Required Entitlements

```xml
<!-- Main App -->
<key>com.apple.developer.family-controls</key>
<array>
    <string>com.apple.developer.family-controls.app</string>
</array>

<!-- Shield Extension -->
<key>com.apple.developer.family-controls</key>
<array>
    <string>com.apple.developer.family-controls.app</string>
</array>
```

### Xcode Project Setup

1. **Create new Xcode project** → iOS App → SwiftUI
2. **Bundle ID**: `com.yourcompany.readdeadredemption`
3. **Minimum deployment**: iOS 18.0

#### Capabilities to Enable:
- Family Controls
- App Groups (`group.com.yourcompany.readdeadredemption`)
- Background Modes (Background fetch, Background processing)
- Push Notifications

#### Add Extensions:
1. File → New → Target → **Shield Configuration Extension**
2. File → New → Target → **Device Activity Monitor Extension**
3. File → New → Target → **Widget Extension**

#### App Group Configuration:
All targets (main app + extensions) must share the same App Group:
`group.com.yourcompany.readdeadredemption`

### Provisioning Profile Setup

1. Go to developer.apple.com → Certificates, Identifiers & Profiles
2. Create App ID with Family Controls capability
3. Request Family Controls entitlement (takes 1-3 business days)
4. Create provisioning profiles for all targets
5. Ensure all extensions use the same team and App Group

### App Store Compliance

**Potential Rejection Risks:**
- Using Screen Time APIs for non-parental/non-self-improvement purposes
- Not clearly explaining data usage in privacy manifest
- Shield UI misleading users
- App not functioning without Screen Time permissions

**Mitigations:**
- Clear value proposition: self-improvement tool
- Transparent permission requests with explanations
- Graceful degradation without permissions
- Privacy manifest declaring all data access

### Monetization Strategy

1. **Freemium Model:**
   - Free: 1 app block, 10 pages/day goal, basic analytics
   - Pro ($4.99/mo): Unlimited blocks, custom goals, advanced analytics, focus mode
   - Lifetime ($39.99): All features forever

2. **Revenue Streams:**
   - Subscription (primary)
   - One-time lifetime purchase
   - No ads (premium positioning)

### Testing Strategy

- Unit tests for AntiCheat engine, ReadingTracker, data models
- UI tests for onboarding flow, reading session
- Integration tests for Screen Time API (device only)
- Beta testing via TestFlight (Screen Time requires real devices)

### Future Roadmap

1. v1.1: Apple Watch companion, widgets
2. v1.2: Social features, reading groups
3. v1.3: AI summaries, OCR scanning
4. v2.0: Cross-platform (iPad, Mac via Catalyst)
