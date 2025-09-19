
# Lively Budget Manager 📊

[![Flutter CI](https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>/actions/workflows/ci.yml/badge.svg)](https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>/actions/workflows/ci.yml)

Lively is a simple, beautiful, and 100% offline monthly expense manager built with Flutter. It helps you track your spending against a monthly budget in a clean and intuitive interface.



## ✨ Features

* **Offline First:** All your data is stored securely on your device. No internet connection is needed.
* **Budget Tracking:** Set a monthly budget and see your remaining funds at a glance.
* **Visualized Spending:** A beautiful donut chart on the home screen visualizes your spending progress.
* **Event History:** Add, edit, and delete expenses. View a complete history of all your transactions.
* **Data Backup & Restore:** Export your budget and transaction data to a JSON file and import it anytime.
* **Personalization:** Set a profile picture and nickname.
* **Theming:** Supports both **Light** and **Dark** modes.
* **Multi-language Support:** Fully localized for English and Portuguese.

---

## 🛠️ Tech Stack & Architecture

This project is built with a modern, scalable, and testable architecture.

* **Framework:** [Flutter](https://flutter.dev/)
* **State Management:** [Flutter Riverpod](https://riverpod.dev/)
* **Navigation:** [go_router](https://pub.dev/packages/go_router)
* **Database:** [sqflite](https://pub.dev/packages/sqflite) for local SQL persistence.
* **UI:**
    * **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
    * **Image Handling:** [image_picker](https://pub.dev/packages/image_picker)
* **Testing:**
    * Unit, Widget, and Integration tests.
    * **Mocking:** [Mocktail](https://pub.dev/packages/mocktail)
    * **Database Testing:** [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
* **CI/CD:** [GitHub Actions](https://github.com/features/actions) for automated testing, analysis, and builds.

The architecture follows a clean, layered approach:

**UI (Screens/Widgets) → State (Riverpod Notifiers) → Repository → Data Source (SQLite)**

---

## 📂 Project Structure

The project is organized into logical directories to maintain a clean and scalable codebase.

```

lib
├── core
│   ├── constants.dart
│   ├── db
│   ├── router.dart
│   ├── theme.dart
│   └── utils
├── l10n
├── models
├── providers
├── screens
├── services
└── widgets

````

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK (version 3.19.0 or higher)
* An IDE like VS Code or Android Studio

### Installation

1.  **Clone the repo**
    ```sh
    git clone [https://github.com/](https://github.com/)<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd lively
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Run the app**
    ```sh
    flutter run
    ```

---

## ✅ Running Tests

This project has a comprehensive suite of tests.

1.  **Run Unit & Widget Tests:**
    ```sh
    flutter test
    ```
2.  **Run Integration Tests:**
    ```sh
    flutter test integration_test
    ```
3.  **Calculate Test Coverage:**
    ```sh
    flutter test --coverage
    ```

---

## 🤖 Continuous Integration

This project uses **GitHub Actions** for its CI pipeline. The workflow, defined in `.github/workflows/ci.yml`, automatically performs the following on every push or pull request to the `main` branch:

1.  **Verifies Formatting:** Checks that all code is correctly formatted.
2.  **Analyzes Code:** Runs static code analysis to catch potential errors.
3.  **Runs Tests:** Executes the full test suite (unit, widget, integration).
4.  **Generates Coverage:** Calculates test coverage and uploads the report to Codecov.
5.  **Builds APK:** Compiles a release-ready Android APK.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.
````