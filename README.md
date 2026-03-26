**Instagram Clone - Flutter & Firebase**

A full-featured Instagram clone built with Flutter, focused on scalability and clean code architecture. This project was developed as a graduation requirement, implementing complex UI/UX and real-time backend integration.

**Key Features**

Authentication: Secure Login and Sign-up using Firebase Auth.

Social Feed: Create posts with multiple images and videos.

Cloud Integration: Managed media uploads using Cloudinary to optimize storage and performance.

Real-time Interaction:

Like and comment system.

Real-time Chatting using Firebase Realtime Database.

Follow/Unfollow functionality and user search.

Stories: Add and view user stories.

Dynamic UI:

Support for Light/Dark Mode.

Multi-language support (English & Arabic).

Fully responsive Profile and Edit Profile screens.

**Tech Stack & Architecture**

Frontend:Flutter (Dart).

Backend: Firebase (Auth, Firestore, Realtime Database).

Media Management: Cloudinary API (for cost-effective and fast image/video hosting).

Architecture: Clean Architecture with a dedicated Core layer for reusable widgets and utilities to ensure high maintainability.

State Management: Optimized for clean logic separation.

**Project Structure**

The project follows a modular structure:

core/: Global widgets, constants, and themes used across the app.

features/: Specific modules (Auth, Post, Chat, Profile) containing their own logic and UI.
