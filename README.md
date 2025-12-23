# ☕ BrewByte

> **The Smart Way to Order Your Campus Brew.** 🚀

## 📱 App Overview

**BrewByte** is a modern, high-performance Flutter mobile application designed to streamline the canteen and cafe experience for university campuses. It bridges the gap between hungry students and busy cafe managers by providing a seamless digital ordering platform.

*   **For Students:** Browse the menu, customize orders, manage your cart, and track order status in real-time.
*   **For Managers:** Efficiently manage menu items, update stock, view incoming orders, and handle user profiles.

## ✨ Key Features

*   **🔐 Role-Based Authentication:** Secure login and sign-up flow powered by Supabase, with distinct experiences for **Students** and **Managers**.
*   **🍔 Dynamic Menu Management:** Managers can add, edit, and upload images for menu items directly from the app.
*   **🛒 robust Cart System:** Add multiple items, adjust quantities, and review orders before checkout.
*   **👤 Profile Management:** Users can update their personal details and manage their account settings.
*   **🎨 Modern Dark UI:** A stunning, "Deep Matte Black" & "Golden Yellow" aesthetic designed for visual appeal and accessibility.
*   **🖼️ Image Handling:** Integrated image picker and upload services for menu items and profiles.

## 🛠 Tech Stack

This project is built using industry-standard technologies and best practices:

*   **Framework:** [Flutter](https://flutter.dev/) (Dart) 💙
*   **State Management:** [Flutter Bloc](https://pub.dev/packages/flutter_bloc) (Business Logic Component pattern)
*   **Backend & Auth:** [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage) ⚡
*   **Routing:** [GoRouter](https://pub.dev/packages/go_router) for declarative navigation.
*   **Equality:** [Equatable](https://pub.dev/packages/equatable) for value comparison.
*   **Media:** [Image Picker](https://pub.dev/packages/image_picker) for device gallery access.

## 📂 Project Architecture

The project follows a clean, feature-driven, layered architecture to ensure scalability and maintainability:

```
lib/
├── bloc/              # Business Logic Components (State Management)
│   ├── auth/          # Authentication Logic
│   └── cart/          # Shopping Cart Logic
├── models/            # Data Models (JSON Serialization/Deserialization)
├── screens/           # UI Screens & Pages
│   ├── menu_screens/  # Menu Browsing & Management
│   └── order_screens/ # Order History & Details
├── services/          # Data Layer (API Calls to Supabase)
├── widgets/           # Reusable UI Components
├── routes/            # Navigation Configuration (GoRouter)
└── main.dart          # Entry point & Theme setup
```

**Data Flow:**
1.  **UI** triggers an **Event** (e.g., `AddCartItem`).
2.  **Bloc** processes the event and calls a **Service**.
3.  **Service** communicates with **Supabase**.
4.  **Bloc** emits a new **State** with data or error.
5.  **UI** listens to state changes and rebuilds.

## 🚀 Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/brewbyte.git
    cd brewbyte
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```
    *   *Tip: Ensure you have an emulator running or a physical device connected.*

## 📸 Screenshots / UI Flow

| Login Screen | Home (Student) | Menu Details | Cart |
| :---: | :---: | :---: | :---: |
| *(Place Screenshot Here)* | *(Place Screenshot Here)* | *(Place Screenshot Here)* | *(Place Screenshot Here)* |

## 📦 Critical Dependencies

*   `supabase_flutter`: ^2.10.3
*   `flutter_bloc`: ^9.1.1
*   `go_router`: ^17.0.0
*   `image_picker`: ^1.2.1

---

*Built with ❤️ and ☕ by the BrewByte Team.*