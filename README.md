# todo_tracker

📦 Packages Used

flutter — Core SDK for building the UI and app logic.

cupertino_icons — Provides iOS-style system icons.

http — Used for making API requests to sync todos with the server.

connectivity_plus — Detects internet connection status (online/offline).

flutter_bloc — Manages app state using the BLoC and Cubit pattern.

equatable — Simplifies equality checks for BLoC states and events.

sqflite — Local SQLite database for offline todo storage.

shared_preferences — Stores simple key-value data like theme mode.

google_fonts — Applies custom Google Fonts for better UI appearance.

permission_handler — Requests and manages runtime permissions (e.g., storage access).

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🚀 Setup and Run Instructions

Clone the repository

git clone https://github.com/anand-pro-dev/Flutter_Todo_offline_app_assessment..Kerala-.git
cd Flutter_Todo_offline_app_assessment..Kerala-


Install dependencies

flutter pub get


Run the app

flutter run


(Optional) Clean and rebuild

flutter clean
flutter pub get

---------------------------------------------------------------------------------------------------------------------------------------------------------



🧩 Folder Structure
lib/
├── data/
│   ├── models/
│   │   ├── todo_model.dart
│   │   └── sync_operation.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── local_db_service.dart
│   └── repository/
│       └── todo_repository.dart
│
├── logic/
│   ├── blocs/
│   │   ├── todo_bloc.dart
│   │   ├── todo_event.dart
│   │   └── todo_state.dart
│   └── cubits/
│       ├── connectivity_cubit.dart
│       ├── theme_cubit.dart
│       └── theme_state.dart
│
├── presentation/
│   ├── screens/
│   │   └── todo_screen.dart
│   └── widgets/
│       └── todo_item_tile.dart
│
└── main.dart


