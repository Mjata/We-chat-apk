# Blueprint: Flutter Dating App

## Overview

This document outlines the architecture, features, and design of the Flutter Dating App. The app is designed to be a modern, engaging, and easy-to-use platform for users to connect with each other.

## Architecture

The app follows a layered architecture pattern, separating concerns into presentation, domain, and data layers. It uses the `go_router` package for declarative navigation and the `provider` package for state management and dependency injection.

### State Management

- **`ThemeProvider`**: Manages the app's theme, allowing users to switch between light, dark, and system themes, and to select a seed color for the color scheme.
- **`UserProfileService`**: Manages the user's profile data, including username, age, location, profile picture, and subscription tier. It listens to real-time updates from Firestore to ensure the UI is always in sync.

### Navigation

The app uses `go_router` for all navigation. The routes are defined in `lib/main.dart` and include paths for:

- Signup and onboarding screens (`/`, `/gender`, `/interest`, `/welcome`)
- The main app screen (`/main`)

### Data

- **Firebase Firestore**: Used as the primary database for storing user profiles and other app data.
- **Firebase Authentication**: Used for user authentication, including email/password and Google Sign-In.
- **`api_service.dart`**: A service class for making API calls to the PesaPal payment gateway.

## Features

### User Authentication

- Users can sign up and log in using email and password.
- Google Sign-In is integrated for a seamless authentication experience.

### Onboarding

- New users go through an onboarding process where they select their gender and interests.
- A welcome screen is shown after the onboarding process is complete.

### Main Screen

The main screen is a `BottomNavigationBar`-based layout with five tabs:

1.  **Home**: The main feed where users can see potential matches.
2.  **Message**: For private conversations with matches.
3.  **Calls**: For voice and video calls.
4.  **Live**: For live streaming.
5.  **Profile**: The user's profile, where they can edit their information, see their coin balance, and access settings.

### Profile Customization

- Users can upload a profile picture.
- Users can edit their username, age, and location.
- Users can add up to three additional photos to their profile.

### Coin System & Payments

- The app has a virtual currency (`coins`) that users can purchase.
- The `recharge_list_screen.dart` displays different coin packages.
- Users can initiate a payment using M-Pesa by entering their phone number.
- The app uses the `webview_flutter` package to display a secure PesaPal payment gateway within the app.
- The `UserProfileService` listens for real-time updates to the user's coin balance in Firestore.

## Design

The app uses Material Design 3 and the `google_fonts` package for a modern and visually appealing UI.

### Theming

- The app supports light and dark themes.
- The color scheme is generated from a seed color, which can be customized by the user.
- Component themes are used to ensure a consistent look and feel for widgets like `AppBar` and `ElevatedButton`.

### Widgets

- **`ProfileFrame`**: A custom widget that displays a user's profile picture with a colored frame based on their subscription tier.
- **`RechargePackage` cards**: Custom-designed cards with gradients and shadows to make the coin packages visually appealing.
