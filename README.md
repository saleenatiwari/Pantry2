<div align="center">

```
██████╗  █████╗ ███╗   ██╗████████╗██████╗ ██╗   ██╗
██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝██╔══██╗╚██╗ ██╔╝
██████╔╝███████║██╔██╗ ██║   ██║   ██████╔╝ ╚████╔╝ 
██╔═══╝ ██╔══██║██║╚██╗██║   ██║   ██╔══██╗  ╚██╔╝  
██║     ██║  ██║██║ ╚████║   ██║   ██║  ██║   ██║   
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   
```

**Your pocket fridge. Your planet's ally.**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-0071E3?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![iOS](https://img.shields.io/badge/iOS-17%2B-black?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/ios/)
[![SwiftData](https://img.shields.io/badge/SwiftData-on--device-34C759?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/xcode/swiftdata/)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-MVP%20in%20progress-orange?style=flat-square)]()

</div>

---

## 🌿 What is Pantry?

Pantry is a native iOS app that turns your fridge into something you actually manage — and your grocery habits into something that matters.

We already produce enough food to feed twice the global population. Yet 1/3 of it is wasted. In wealthy societies, that waste doesn't happen at a policy level — it happens quietly, in household fridges, one forgotten bag of spinach at a time. Pantry closes that feedback loop in real time.

Scan what you buy. Track what you have. Cook what's about to expire. Understand what you're actually putting in your body — and what it costs the planet.

> *"If Yuka and a nutrition tracker had a baby."*

---

## ✨ Features

### 📦 Inventory Management
- Scan product barcodes to instantly identify items via the **Open Food Facts API**
- Items are auto-sorted into storage sections — Fridge, Freezer, Shelf, Pantry, Basement
- Visual expiry urgency indicators: fresh → expiring soon → expired
- Swipe to delete or mark items as **Eaten!**
- Full-grid inventory view with section-level drill-down

### 🤖 AI Recipe Chef
- Powered by **Gemini AI** — suggests recipes based on what's currently in your inventory
- Prioritizes ingredients expiring soonest to minimize waste
- Voice-guided cooking instructions via **ElevenLabs** *(coming soon)*
- No calorie obsession — focused on real nutrition and using what you have

### 🌍 Impact Scores *(in development)*
- Every scanned product gets a **health score** and a **CO₂ footprint score**
- Smarter swaps: *"You eat avocado daily — try sunflower seed butter: same healthy fats, 80% lower footprint"*
- Breaks the transparency gap between what you eat and what it costs — your body and the environment

### 🔔 Expiry Notifications *(in development)*
- 8 PM day-before alerts for items about to expire
- Notifications auto-cancel when items are marked eaten or deleted

---

## 🏗️ Architecture

```
Pantry/
├── Models/
│   └── FoodItem.swift          # SwiftData @Model — core data entity
├── Services/
│   ├── FoodAPIService.swift     # Open Food Facts API integration
│   └── GeminiService.swift      # Gemini AI for expiry estimation & recipes
├── Views/
│   ├── InventoryView.swift      # Tab 1 — LazyVGrid inventory with sections
│   ├── ScannerView.swift        # Tab 2 — AVFoundation barcode scanner
│   ├── ChefView.swift           # Tab 3 — AI recipe suggestions
│   ├── SectionDetailView.swift  # Drill-down per storage section
│   ├── FoodItemRow.swift        # Individual item row with urgency indicator
│   └── AddToInventorySheet.swift # Post-scan save flow
└── Secrets.swift                # API keys (gitignored)
```

**Stack:**
| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData (on-device) |
| Barcode Scanning | AVFoundation via `UIViewRepresentable` |
| Food Data | Open Food Facts API (free, no key required) |
| AI / Recipes | Google Gemini API |
| Voice Guidance | ElevenLabs *(planned)* |
| Distribution | TestFlight → App Store |

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+ simulator or physical device
- A [Gemini API key](https://aistudio.google.com/) (free tier works)

### Setup

```bash
git clone https://github.com/saleenatiwari/Pantry2.git
cd Pantry2
```

1. Open `Pantry2.xcodeproj` in Xcode
2. Create `Secrets.swift` in the project root:

```swift
// Secrets.swift — do not commit, already in .gitignore
enum Secrets {
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY_HERE"
}
```

3. Select your target device or simulator
4. Hit **Run** ▶️

> Camera permissions are required for barcode scanning. The app will prompt on first launch — make sure `NSCameraUsageDescription` is present in `Info.plist` (it already is).

---

## 📋 Roadmap

```
✅ Phase 1 — Core MVP
   ✅ Three-tab structure (Inventory, Scanner, Chef)
   ✅ Barcode scanner via AVFoundation
   ✅ Open Food Facts API integration
   ✅ SwiftData persistence (FoodItem, StorageSection, ExpiryUrgency)
   ✅ Inventory grid with section drill-down
   ✅ Swipe actions (delete, eaten)
   ✅ AddToInventorySheet
   ✅ Gemini expiry date estimation with 7-day fallback

🔨 Phase 2 — Intelligence Layer (in progress)
   ⬜ AI recipe suggestions in Chef tab
   ⬜ ElevenLabs voice cooking guidance
   ⬜ Expiry push notifications (UNUserNotificationCenter)
   ⬜ Manual item entry flow
   ⬜ Health + CO₂ impact scores per product

🌱 Phase 3 — Growth
   ⬜ App Store submission
   ⬜ Shared pantry (roommates / families)
   ⬜ Smarter swap suggestions
   ⬜ Campus workshop integration
```

---

## 🧠 Design Decisions

**Why SwiftData over CoreData or a backend?**
On-device persistence is the right call for an alpha. No auth, no latency, no infrastructure costs. SwiftData's `@Model` macro keeps the code clean. Cloud sync is a Phase 3 problem.

**Why a 7-day fallback for Gemini expiry estimates?**
The Gemini free tier hits quota limits quickly. A hardcoded 7-day default is an honest, user-safe fallback — better than crashing or showing nothing. Users can always edit manually.

**Why `displayName` computed properties on enums?**
SwiftData migrations crash when raw values change. Keeping raw values stable and using `displayName` for display strings means we can rename "Pantry" → "Shelf" in the UI without a schema migration.

---

## 🌱 The Bigger Picture

Pantry is being built as part of a broader effort to tackle household food waste through behavior change — not lectures. The hypothesis: when people can see what they have, understand what it's worth (nutritionally and environmentally), and get frictionless guidance on how to use it, they waste less. Not because they're told to. Because it's easy not to.

This is an MVP. It's scrappy. It's being built by one person, for themselves first, and then for everyone else.

---

## 👩‍💻 Author

**Saleena Tiwari**
Computer Science @ Georgia Institute of Technology
Climate activist. Nutrition workshop facilitator. Builder.

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

*Built with 🌿 in Atlanta, Georgia*

</div>
