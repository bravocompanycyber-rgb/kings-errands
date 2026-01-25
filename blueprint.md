# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the Flutter application. It serves as a living document that will be updated as the project evolves.

## Style, Design, and Features

### Theming

- **Color Scheme:** The app uses a Material 3 theme generated from a primary seed color (`#6C63FF`) and a secondary color (`#F5A623`).
- **Typography:** Custom fonts are implemented using the `google_fonts` package. `Oswald` is used for display text, `Roboto` for titles, and `Open Sans` for body text.
- **Component Styles:** The `AppBar` and `ElevatedButton` widgets have been styled for a consistent look and feel.
- **Dark/Light Mode:** The app supports both light and dark themes and defaults to the system theme.

### Navigation

- **Routing:** The app uses the `go_router` package for declarative navigation.
- **Authentication Flow:**
  - The app starts with a `SplashScreen` that handles the initial authentication check.
  - Unauthenticated users are directed to the `LoginScreen`.
  - Authenticated users are redirected to their role-specific dashboards (`CustomerHomeScreen`, `RunnerHomeScreen`, or `AdminDashboardScreen`).
  - The router protects routes to ensure that only authenticated users can access protected areas of the app.

### Authentication

- **Firebase Auth:** The app uses Firebase Authentication to manage user accounts.
- **Role-Based Access Control:** Users can have one of three roles: `Customer`, `Runner`, or `Admin`. The app's navigation and UI are tailored to the user's role.
- **Signup:** The `SignupScreen` is configured to only allow the creation of `Customer` accounts.

## Current Task: Initial Setup and Theming

- **Objective:** To create a new Flutter project, set up a custom theme, and implement a robust navigation system with authentication and role-based access control.
- **Steps Taken:**
  1. Created a new Flutter project.
  2. Implemented a custom theme with Material 3, `google_fonts`, and custom component styles.
  3. Set up `go_router` for declarative navigation.
  4. Implemented an authentication flow with a `SplashScreen` that handles initial routing.
  5. Created placeholder screens for the different user roles and features.
  6. Fixed various issues related to Firebase initialization, package dependencies, and navigation logic.
