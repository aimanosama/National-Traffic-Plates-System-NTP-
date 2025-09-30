# National Traffic Plates System (NTP)

A Flutter-based mobile application for the National Traffic Plates System, featuring user authentication, responsive UI design, and modern animations.

## Features

- **User Authentication**: Phone number-based login and registration system
- **Responsive Design**: Optimized for different screen sizes and orientations
- **Modern UI**: Dark theme with network-based images and animations
- **Animated Welcome Screen**: Color-changing text animations for engaging user experience
- **Navigation**: Curved bottom navigation bar for intuitive user interaction

## Tech Stack

- **Flutter**: Cross-platform mobile development framework
- **BLoC Pattern**: State management for predictable and testable code
- **Go Router**: Declarative routing with authentication-based navigation
- **Google Fonts**: Montserrat font family for consistent typography
- **Animated Text Kit**: Text animations for enhanced user experience

## Getting Started

### Prerequisites
- Flutter SDK (>=3.6.1)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/aimanosama/National-Traffic-Plates-System-NTP-.git
cd National-Traffic-Plates-System-NTP-
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/                   # Core utilities and configurations
│   ├── app_colors.dart    # Color constants and theme colors
│   ├── app_theme.dart     # Application theme configuration
│   └── router.dart        # Navigation and routing setup
├── features/              # Feature-based architecture
│   └── auth/             # Authentication feature
│       ├── domain/       # Business logic and entities
│       └── presentation/ # UI components and state management
├── main.dart             # Application entry point
└── main_wrapper.dart     # Main navigation wrapper
```

## Team

This project is developed as part of the DEPI (Digital Egypt Pioneers Initiative) program.

## License

This project is developed for educational purposes as part of the DEPI program.
