# Pricing Configuration

## Monetization Model: Freemium (Free + One-Time Purchase)

LunaLock uses a freemium model with a one-time in-app purchase to unlock Pro features. This aligns perfectly with the privacy-first positioning — no subscription means no payment data to track, no recurring billing relationship.

## App Store Connect Pricing

- **Base App Price**: Free (Tier 0)
- **Pro Upgrade**: $3.99 one-time (Non-Consumable IAP)

## IAP Product Details

### LunaLock Pro Upgrade
- **Reference Name**: LunaLock Pro
- **Product ID**: `com.zzoutuo.LunaLock.pro`
- **Type**: Non-Consumable
- **Price**: $3.99 (one-time purchase)
- **Display Name**: LunaLock Pro
- **Description**: Unlock all premium features forever

## Feature Tier Breakdown

### Free Tier
- Period start/end logging with haptic feedback
- Cycle prediction with confidence range
- Basic symptom tracking (6 preset symptoms)
- Calendar view with period/prediction markers
- FaceID/PIN lock + emergency shake-to-lock
- Auto-lock timer
- 100% local storage, zero cloud
- No ads, no accounts
- Onboarding privacy promise
- Data deletion

### Pro Tier ($3.99 one-time)
- All Free tier features
- Trend charts (cycle length, symptom frequency, mood patterns)
- Custom symptom creation (unlimited)
- Data export (PDF for doctors / JSON for other apps)
- Home screen widget (countdown + cycle day)
- Theme customization (5 color schemes)
- HealthKit write-only integration (optional)
- Monthly/annual cycle report
- Emergency shake-to-lock
- All future updates included

## Why One-Time Purchase (Not Subscription)

| Factor | One-Time Purchase | Subscription |
|--------|------------------|--------------|
| Privacy alignment | Perfect — no payment data to track | Contradicts privacy promise |
| User trust | High — one transaction, done | Low — "why do you need my card?" |
| Competitive differentiation | Extreme — only privacy app with buy-once | None — Flo/Clue both use subscriptions |
| Marketing message | "$3.99. Forever." | "Another $4.99/month..." |
| No API/server costs | Supports one-time model | Not needed |

## Policy Pages Required
- Support Page: YES
- Privacy Policy: YES
- Terms of Use: NO (not required for non-subscription apps; however, since IAP is involved, we will include Terms for best practice)

## Apple IAP Compliance Checklist
- [x] Non-consumable product type correctly configured
- [x] Restore purchases functionality will be implemented
- [x] Price clearly stated in Paywall
- [x] Feature list clearly shown before purchase
- [x] No dark patterns or forced upgrades
- [x] Free tier is fully functional without Pro
