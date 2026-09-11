# 🪔 Pocket Puja

**A digital sanctuary for daily rituals** — Telugu devotional chants, Panchangam, Poojari booking, and a devotional shop, all in one app.

> This repository is a **UI/frontend prototype**. There is no backend, database, or real authentication — all content is mock data, organized under `lib/data/`, so the interface can be reviewed and demoed end-to-end before backend work begins.

---

## ✨ Features

- **Home** — daily Panchangam glance, active booking & upcoming festival alerts, day-of-week deity audio picks
- **Music** — Telugu chants & podcasts with synced lyrics, script switching (Telugu / Roman / Meaning), usage tracking
- **Booking** — occasion-first Poojari booking flow, live status tracking, items checklist, ratings
- **Shop** — devotional essentials, seasonal specials, cart & checkout
- **Calendar** — full Panchangam (Tithi, Nakshatram, Rahu Kalam, etc.), festival highlights, Rashi Phalam
- **Profile** — personal info, saved addresses, order history, notification preferences

## 🎨 Design

Built around a **"Liquid Glass"** visual language — frosted glass panels, a warm golden gradient background, and glowing gold accents throughout, matching Apple's iOS 26 design direction.

## 🛠 Tech Stack

- **Flutter** (Dart) — cross-platform UI
- **Google Fonts** — Plus Jakarta Sans + Noto Sans Telugu
- **Cached Network Image** — image loading/caching
- No backend, no state persistence — this is a UI-only prototype

## 📁 Project Structure

- lib/data — mock/sample data, organized per module
- lib/widgets — reusable UI components, organized per module
- lib/screens — full screens, organized per module
- lib/theme — design tokens (colors, gradients, text styles)

## 🚀 Getting Started

Run these two commands to get the app running:

flutter pub get
flutter run

To regenerate the app icon after changing assets/icon/icon.png, run:

flutter pub run flutter_launcher_icons

## 📦 Building a Release APK

A GitHub Actions workflow is set up under `.github/workflows/build-apk.yml`. Go to the **Actions** tab on GitHub, select **Build APK**, and click **Run workflow** to trigger a build manually. Once it finishes, download the APK from that run's **Artifacts** section.

To build locally instead, run:

flutter build apk --release

The output APK will be at build/app/outputs/flutter-apk/app-release.apk

## ⚠️ Prototype Status

This is a **frontend-only prototype** for design/product review. Features like login, payments, bookings, and orders are simulated with short delays and static data — nothing is persisted or sent to a real server.