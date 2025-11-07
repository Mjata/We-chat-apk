# Chat App Blueprint

## Overview

This document outlines the plan and features for a new Flutter chat application. The goal is to create a modern, visually appealing, and user-friendly app.

## Implemented Features

### Phase 1: Onboarding and Main Screen

1.  **Welcome Screen:**
    *   Displays a chat icon.
    *   Includes Google and Facebook sign-in buttons.
    *   Designed with a modern and beautiful UI.

2.  **Gender Selection Screen:**
    *   Allows users to select their gender.

3.  **Interest Selection Screen:**
    *   Allows users to choose between "Relationship" or "Friendship".

4.  **Main Screen:**
    *   Implemented a 5-item bottom navigation bar with the following tabs:
        *   **Home:** Displays a list of dummy users with profile pictures.
        *   **Message:** Displays a list of dummy conversations.
        *   **Calls:** Displays a history of dummy calls.
        *   **Live:** Displays a grid of users who are currently "live".
        *   **Profile:** Displays a user profile with a profile picture, bio, and a grid of photos.

### Theming

*   **Material 3:** The app now uses Material 3 theming for a modern look and feel.
*   **Color Scheme:** A harmonized color palette is generated from a seed color (`Colors.deepPurple`).
*   **Typography:** The app uses custom fonts from `google_fonts` (`Oswald`, `Roboto`, `Open Sans`).
*   **Dark/Light Mode:** A theme toggle has been implemented, allowing users to switch between light and dark modes.
*   **State Management:** The `provider` package is used to manage the theme state.

## Next Steps

*   Implement real-time chat functionality using Firebase.
*   Connect the app to a backend to fetch real user data.
*   Add authentication to the sign-in buttons.
