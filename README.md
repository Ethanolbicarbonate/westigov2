[![Westigo Logo](assets/images/logo.svg)](https://github.com/ethanolbicarbonate/westigov2)

The official mobile companion for West Visayas State University (WVSU) students.
Navigate the campus, discover events, and locate facilities seamlessly.

[Key Features](https://www.google.com/search?q=%23-key-features) • [Tech Stack](https://www.google.com/search?q=%23-tech-stack) • [Getting Started](https://www.google.com/search?q=%23-getting-started) • [Configuration](https://www.google.com/search?q=%23configuration)

-----

## 📋 Overview

Westigo is a cross-platform mobile application built with Flutter, designed to help WVSU students and visitors navigate the university campus. It provides an interactive map based on OpenStreetMap, a directory of facilities and spaces, and a centralized hub for campus events. Powered by Supabase, it ensures real-time data synchronization and secure authentication.

## ✨ Key Features

### Student Authentication

  * **Secure Login & Signup** utilizing Supabase Auth.
  * **Academic Context:** Captures course and year level during registration to personalize content.
  * **Password Recovery:** Integrated reset password functionality via email.

### Interactive Campus Map

  * **OpenStreetMap Integration:** Zoomable and pannable map of the WVSU campus.
  * **Facility Markers:** Interactive pins for major buildings; tapping opens a quick preview sheet.
  * **Navigation Tools:** "Recenter" button to quickly return to the campus view.

### Smart Search

  * **Global Search Bar:** Find Facilities (buildings) or Spaces (rooms/labs) instantly.
  * **Fuzzy Matching:** Implements intelligent search logic to handle typos and partial keywords.

### Event Discovery

  * **Campus Feed:** Browse upcoming university events with cover images and details.
  * **Smart Filtering:** Filter events by **Year Level** or **College** to find relevant activities.
  * **Sharing:** Built-in sharing capabilities to send event or location details to other apps.

### Favorites & Bookmarking

  * **Personalized Lists:** Save frequently visited facilities, specific rooms, or upcoming events.
  * **Optimistic UI:** Instant visual feedback when toggling favorites.

### User Profile

  * **Account Management:** Update profile picture (stored in Supabase Storage), change passwords, or update email.
  * **Stats:** View user-specific statistics like "Member Since" and favorites count.

## 🛠️ Tech Stack

### Mobile Core

  * **Framework:** Flutter (Dart)
  * **State Management:** Riverpod (Providers, StateNotifiers)
  * **Navigation:** Native Flutter Routing with custom transitions (SlideUp, Fade)

### Data & Backend

  * **BaaS:** Supabase (Auth, Database, Storage)
  * **SDK:** `supabase_flutter`

### Maps & Location

  * **Rendering:** `flutter_map` (OpenStreetMap)
  * **Coordinates:** `latlong2`

### Utilities

  * **Environment:** `flutter_dotenv`
  * **Media:** `image_picker` (Camera/Gallery access)
  * **Search:** `string_similarity` (Relevance scoring)
  * **Sharing:** `share_plus`

## 🚀 Getting Started

### Prerequisites

  * Flutter SDK (3.2.0 or higher)
  * Dart SDK
  * Android Studio / Xcode (for emulators)
  * A Supabase project

### Installation

1.  **Clone the repository**

    ```bash
    git clone https://github.com/ethanolbicarbonate/westigov2.git
    cd westigov2
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

3.  **Setup Environment Variables**
    Create a `.env` file in the root directory:

    ```bash
    touch .env
    ```

### Configuration

Open your `.env` file and add your Supabase credentials:

```properties
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

> **Note:** Ensure your Supabase project is configured with the `users` (public profile table), `facilities`, `spaces`, `events`, and `favorites` tables.

### Running the App

Start the app on an emulator or connected device:

```bash
flutter run
```

### 📦 Build for Production

To create a release APK (Android):

```bash
flutter build apk --release
```

To create an iOS archive (macOS only):

```bash
flutter build ios --release
```

## 📂 Project Structure

```text
lib/
├── config/          # Configuration files (Theme, Supabase, DotEnv)
├── models/          # Data models (Event, Facility, Space, User)
├── providers/       # Riverpod state providers
├── screens/         # UI Screens (Map, Events, Profile, Auth)
│   ├── auth/        # Login, Signup, Reset Password
│   ├── events/      # Event listing and details
│   ├── favorites/   # Saved items tab
│   ├── map/         # Map view and search
│   └── profile/     # User settings and editing
├── services/        # API service layer (Supabase interaction)
├── utils/           # Helper functions, constants, and validators
├── widgets/         # Reusable UI components (Cards, Buttons, Sheets)
└── main.dart        # Application entry point
```

## 🤝 Contributing

Contributions are welcome\! Please feel free to submit a Pull Request.

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See LICENSE for more details.

-----

*Built with 💙 by the Westigo Development Team*
