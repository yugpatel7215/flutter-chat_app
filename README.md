# Chat App

A real-time one-to-one chat application built with Flutter, Dart, Firebase Authentication, Cloud Firestore, and Riverpod.

## Features

* User registration and login
* Email verification
* Forgot password
* User search
* User profiles
* Edit profile
* Profile photo
* Send friend requests
* Cancel friend requests
* Accept friend requests
* Reject friend requests
* Friends list
* Real-time friendship updates
* Real-time one-to-one chat
* Persistent message history
* Deterministic chat IDs
* Real-time Firestore updates

## Tech Stack

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Riverpod
* Material UI

## Architecture

The application follows a layered architecture:

```text
UI
 ↓
Provider
 ↓
Controller
 ↓
Repository
 ↓
Firebase / Firestore
```

### UI

Handles screens, widgets, user interaction, and displaying application state.

### Provider

Exposes application state to the UI using Riverpod.

### Controller

Handles application actions and write operations.

### Repository

Handles Firebase and Firestore operations.

The UI does not communicate directly with Firestore.

## Project Structure

```text
lib/
│
├── core/
│
├── features/
│
├── auth/
│   ├── controllers/
│   ├── data/
│   ├── providers/
│   └── presentation/
│
├── profile/
│   ├── controllers/
│   ├── providers/
│   ├── repository/
│   └── presentation/
│       ├── screens/
│       └── widget/
│
├── friends/
│   ├── controllers/
│   ├── data/
│   │   ├── enum/
│   │   └── models/
│   ├── providers/
│   ├── repository/
│   └── presentation/
│       ├── pages/
│       └── widgets/
│
├── chat/
│   ├── controllers/
│   ├── data/
│   │   ├── models/
│   │   └── repository/
│   ├── providers/
│   └── presentation/
│
└── main.dart
```

## Firestore Structure

### Users

```text
users/
└── userId
    ├── uid
    ├── name
    ├── email
    ├── photoUrl
    ├── about
    ├── onlineStatus
    └── lastSeen
```

### Relationships

```text
relationships/
└── relationshipId
    ├── participants
    ├── senderId
    ├── receiverId
    ├── status
    ├── createdAt
    └── updatedAt
```

Relationship statuses:

```text
pending
accepted
rejected
```

Relationship IDs are generated deterministically from the two participant UIDs.

### Chats

```text
chats/
└── chatId
    ├── participants
    ├── lastMessage
    ├── lastMessageTime
    ├── lastMessageSenderId
    ├── createdAt
    ├── updatedAt
    └── unreadCount
```

### Messages

```text
chats/
└── chatId/
    └── messages/
        └── messageId
            ├── senderId
            ├── receiverId
            ├── text
            ├── chatId
            ├── type
            ├── delivered
            └── seenStatus
```

## Friend Request Model

Incoming friend requests use a combined model containing:

```text
FriendRequestModel
├── UserModel
└── RelationshipModel
```

This allows the UI to access both the sender's information and relationship information without additional relationship lookups.

## Real-Time Data

Firestore streams are used for real-time application data.

```text
Firestore
 ↓
Stream
 ↓
Riverpod Provider
 ↓
UI
 ↓
Automatic Update
```

Real-time functionality includes:

* Chat list updates
* New messages
* Friend requests
* Relationship changes
* Friends list updates

## Application Flow

### Authentication

```text
Login / Register
 ↓
Firebase Authentication
 ↓
Auth State
 ↓
Auth Gate
 ↓
Home
```

### Friend Requests

```text
Search User
 ↓
Open Profile
 ↓
Send Friend Request
 ↓
Relationship Created
 ↓
Incoming Request Stream
 ↓
Accept / Reject
 ↓
Friends List
```

### Chat

```text
Select Friend
 ↓
Generate Chat ID
 ↓
Open Chat
 ↓
Load Messages
 ↓
Send Message
 ↓
Firestore
 ↓
Real-Time Stream
 ↓
Message Appears
```

## Current Status

Basic chat application is complete and the implemented features have been tested.

Implemented:

* Authentication
* User search
* User profiles
* Profile editing
* Friend requests
* Friends management
* Real-time relationship updates
* Chat list
* One-to-one messaging
* Real-time messages
* Firestore persistence

## Future Improvements

* In-app notifications
* Push notifications
* Online/offline presence
* Typing indicators
* Message read receipts
* Message delivery status
* Image and file messages
* Message editing
* Message deletion
* Chat deletion
* Unfriend
* Block/unblock users
* Pagination
* Offline handling
* Unit tests
* Widget tests
* Integration tests
* Improved security rules
* UI/UX improvements

## Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter IDE
* Firebase project
* Firebase Authentication
* Cloud Firestore

### Installation

bash
git clone <your-repository-url>
cd chat_app
flutter pub get
flutter run
```

Configure Firebase for your target platform before running the application.

## Security

Before deploying the application:

* Configure Firestore security rules.
* Restrict unauthorized database access.
* Validate authentication and authorization.
* Protect production credentials.
* Review access rules for users, relationships, chats, and messages.

## Author

YUGPATEL 

Built with Flutter, Dart, Firebase, and Riverpod.
