# Backend Blueprint for Flutter Chat App

## 1. Overview

This document outlines the architecture and specifications for the backend system that will power the Flutter chat application. The backend will be built entirely on the Firebase platform to handle user authentication, real-time data synchronization, application logic, and file storage. The primary goal is to create a scalable, secure, and real-time backend that integrates seamlessly with the frontend application.

---

## 2. Technology Stack

- **Primary Platform**: Firebase
- **Core Services**:
    - **Firebase Authentication**: For user sign-up, sign-in (Email/Password, Google, Facebook), and identity management.
    - **Cloud Firestore**: A NoSQL, real-time database for storing all application data like user profiles, chat messages, and coin balances.
    - **Cloud Functions for Firebase**: For executing server-side logic, such as deducting coins, validating actions, and processing rewards.
    - **Firebase Storage**: For storing user-generated content, primarily profile pictures and photo gallery images.
    - **Google AdMob**: For serving rewarded video ads to users to earn in-app currency.

---

## 3. Cloud Firestore: Database Schema

The database will be structured into the following top-level collections.

### 3.1. `users`

This collection will store the public and private profile data for each user. The document ID for each user will be their unique `uid` from Firebase Authentication.

**Collection**: `users`
**Document ID**: `{uid}`

| Field Name            | Data Type | Description                                                                 | Default Value      |
| --------------------- | --------- | --------------------------------------------------------------------------- | ------------------ |
| `uid`                 | `String`  | The user's unique ID from Firebase Auth.                                     | -                  |
| `username`            | `String`  | The user's display name.                                                     | "New User"         |
| `email`               | `String`  | The user's registration email.                                             | -                  |
| `profilePictureUrl`   | `String`  | URL to the user's profile picture stored in Firebase Storage.              | (URL to a default) |
| `age`                 | `Number`  | The user's age.                                                            | `null`             |
| `location`            | `String`  | The user's location.                                                       | `null`             |
| `gender`              | `String`  | The user's selected gender (e.g., "Man", "Woman").                         | `null`             |
| `interest`            | `String`  | The user's selected interest (e.g., "Friendship", "Relationship").         | `null`             |
| **`coins`**             | **`Number`**  | **The user's current coin balance. Will be updated in real-time.**       | `550`              |
| `subscriptionTier`    | `String`  | User's premium status ("none", "gold", "diamond", "vip").                  | `"none"`           |
| **`dailyAdViews`**      | **`Number`**  | **Tracks the number of rewarded ads watched today.**                          | `0`                |
| **`lastAdViewTimestamp`** | **`Timestamp`** | **Timestamp of the last rewarded ad view for daily reset.**                 | `null`             |
| `createdAt`           | `Timestamp`| The timestamp when the user account was created.                            | Server Timestamp   |
| `lastSeen`            | `Timestamp`| The timestamp of the user's last activity.                               | Server Timestamp   |


### 3.2. `chats`

This collection will manage 1-on-1 chat sessions. Each document represents a conversation between two users and contains a sub-collection for the messages.

**Collection**: `chats`
**Document ID**: `{composite_id}` (e.g., `uid1_uid2` with UIDs sorted alphabetically to ensure uniqueness).

#### Sub-collection: `messages`

**Collection**: `messages`
**Document ID**: `{auto_id}`

| Field Name | Data Type | Description                              |
| ---------- | --------- | ---------------------------------------- |
| `senderId` | `String`  | The `uid` of the message sender.           |
| `text`     | `String`  | The content of the message.              |
| `timestamp`| `Timestamp`| The time the message was sent.           |
| `isRead`   | `Boolean` | `true` if the recipient has read it.     |

---

## 4. Firebase Authentication

- **Providers**: Enable Email/Password, Google Sign-In, and Facebook Sign-In.
- **New User Trigger**: A Cloud Function will be triggered upon the creation of a new user account.
    - **`onUserCreate` Cloud Function**:
        - **Trigger**: `functions.auth.user().onCreate()`
        - **Action**: Automatically create a new document for the user in the `users` collection in Firestore using their `uid` and populate it with the default values specified in the schema.

---

## 5. Cloud Functions: Server-Side Logic & Coin System

These `https.onCall` functions will be the primary interface between the Flutter client and the backend logic, ensuring secure and consistent operations.

### 5.1. `deductCoins`

This function handles all coin deductions for various in-app actions.

- **Trigger**: `https.onCall`
- **Input Data**: `(data, context)` where `data` is an object: `{ action: string, context?: any }`
- **Authentication**: The function must verify `context.auth` exists.
- **Logic**:
    - Reads the `action` field from the input `data`.
    - Retrieves the user's `uid` from `context.auth.uid`.
    - Fetches the user's document from Firestore.
    - Uses a `switch` statement or `if/else` block based on the `action`:
        - **Case `'send_sms'`**:
            - **Cost**: 20 coins.
            - If `user.coins >= 20`, decrement coins by 20.
            - Otherwise, throw an `'insufficient-funds'` error.
        - **Case `'start_voice_call'`**:
            - **Cost**: 160 coins (per minute).
            - Check if `user.coins >= 160`.
            - If not, throw an `'insufficient-funds'` error. If yes, return success (the client will handle per-minute deductions).
        - **Case `'start_video_call'`**:
            - **Cost**: 190 coins (per minute).
            - Check if `user.coins >= 190`.
            - If not, throw an `'insufficient-funds'` error.
    - **Transaction**: All coin deductions **must** be performed inside a Firestore transaction to prevent race conditions.
    - **Return**: `{ success: true }` or throw an appropriate error.

### 5.2. `rewardUserForAd`

This function credits a user's account after they successfully watch a rewarded ad, enforcing a daily limit.

- **Trigger**: `https.onCall`
- **Input Data**: `{}`
- **Authentication**: Must be called by an authenticated user.
- **Logic**:
    - **Reward Amount**: 5 coins.
    - **Daily Limit**: 5 ads per day.
    - **Use a Firestore transaction** to read the user's data and perform updates atomically.
    - **Inside the transaction**:
        1.  Fetch the user document for the authenticated `uid`.
        2.  Retrieve `dailyAdViews` and `lastAdViewTimestamp`.
        3.  Check if `lastAdViewTimestamp` is from a previous day. (A helper function should compare the date part of the timestamp with the current date, ignoring time).
        4.  **If it's a new day**: Reset `dailyAdViews` to `0` in the transaction data.
        5.  **Check the limit**: If the (potentially reset) `dailyAdViews` is less than 5:
            -   Increment `coins` by 5 (`FieldValue.increment(5)`).
            -   Increment `dailyAdViews` by 1 (`FieldValue.increment(1)`).
            -   Set `lastAdViewTimestamp` to the current server timestamp.
            -   Commit the transaction.
            -   Return `{ success: true, message: "You have been rewarded 5 coins." }`.
        6.  **If the limit is reached**:
            -   Throw a `resource-exhausted` error with the message "Daily ad reward limit reached. Please try again tomorrow."


### 5.3. `checkLiveStreamPermission`

This function verifies if a user has the required subscription tier to use the "Go Live" feature.

- **Trigger**: `https.onCall`
- **Input Data**: `{}`
- **Authentication**: Must be called by an authenticated user.
- **Logic**:
    - Fetches the user's document from Firestore.
    - Checks if `user.subscriptionTier === 'vip'`.
    - **Return**:
        - If VIP: `{ canGoLive: true }`.
        - Otherwise: Throws a `'permission-denied'` error with the message "Only VIP members can go live."

---

## 6. Firebase Storage

- **Structure**:
    - `profile_pictures/{uid}/{image_file_name.jpg}`
    - `user_photos/{uid}/{image_file_name.jpg}`
- **Security Rules**:
    - **Profile Pictures**:
        - `allow read: if request.auth != null;` (Any authenticated user can view profile pictures).
        - `allow write: if request.auth.uid == uid;` (A user can only upload/update their own profile picture).
    - **User Photos**:
        - `allow read: if request.auth != null;`
        - `allow write: if request.auth.uid == uid;`

---

## 7. AdMob Integration Flow

1.  **Client-Side (Flutter App)**:
    - User taps the "Get Coins" button.
    - The app loads and shows a **Rewarded Ad** from AdMob.
2.  **Ad Completion**:
    - The user watches the entire ad.
    - The AdMob SDK fires the `onUserEarnedReward` callback on the client.
3.  **Server-Side Call**:
    - Inside the callback, the Flutter client invokes the `rewardUserForAd` Cloud Function.
4.  **Backend Processing**:
    - The `rewardUserForAd` function securely validates the request, checks the daily limit, and updates the user's coin balance in Firestore.
    - The new balance is automatically synced back to the client via Firestore's real-time listener.

---

## 8. Frontend Integration Requirements

This section lists the specific deliverables and information that the frontend (Flutter) development team will require from the backend team once the Firebase project is set up.

### 8.1. Firebase Configuration

- **Required**: The `firebase_options.dart` file.
- **Action**: The backend team must generate this file using the FlutterFire CLI (`flutterfire configure`). This file contains all the necessary API keys and project identifiers for the Flutter app to connect to the correct Firebase project.

### 8.2. Cloud Function Endpoints

- **Required**: Confirmation of the names of the callable Cloud Functions.
- **Details**: The frontend app will invoke these functions directly. Based on this blueprint, the expected names are:
    - `deductCoins`
    - `rewardUserForAd`
    - `checkLiveStreamPermission`

### 8.3. Real-time Data Listeners

- **Required**: No direct deliverable, but the frontend will assume the database schema is implemented as described in Section 3.
- **Details**: The frontend will set up real-time listeners on the following Firestore paths:
    - `users/{uid}`: To listen for changes to the logged-in user's profile, especially the **`coins`** balance, `username`, `subscriptionTier`, and `dailyAdViews`.
    - `chats/{chat_id}/messages`: To listen for new incoming messages in a conversation.

### 8.4. AdMob Ad Unit IDs

- **Required**: The Ad Unit IDs for the Rewarded Video ads.
- **Details**: The backend/project admin team needs to create a Rewarded Ad unit in the Google AdMob console and provide the following IDs to the frontend team:
    - **Android Rewarded Ad Unit ID**: (e.g., `ca-app-pub-3940256099942544/5224354917` for testing)
    - **iOS Rewarded Ad Unit ID**: (e.g., `ca-app-pub-3940256099942544/1712463099` for testing)
