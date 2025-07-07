# Vision Parking App - Frontend UI PRD

## Overview

**Vision Parking App** is a native Android application (Java-based) that enables users to discover, book, and manage parking spaces. This document outlines the **frontend design, UI flow**, and **API integration strategy** for Android Studio. The backend server (Flask + REST API) is already implemented and will be integrated after the UI is complete.

---

## 1. Objectives

- Design intuitive and responsive UI screens.
- Create smooth user navigation through all functional modules.
- Integrate UI with existing Flask-based REST APIs (when available).
- Use placeholders/mock data for screens where APIs are pending or optional.

---

## 2. Target Platform

- **Platform**: Android
- **Language**: Java
- **IDE**: Android Studio
- **Minimum SDK**: 24+
- **UI Toolkit**: Android XML Layouts with Material Components

---

## 3. UI Screens and Flows

### 3.1 Splash Screen
- App logo with animation with Get Started button which redirects user to registration/login page.
- Navigates to Login or Home based on token existence

---

### 3.2 Authentication

#### Login Screen
- Fields: Email, Password
- Buttons: Login, Register (redirects to Registration)
- Token saved locally on success (for auto-login)

#### Registration Screen
- Fields: Name, Email, Phone, Password, Address
- Button: Register
- On success: redirects to Login or Home

---

### 3.3 Home Screen
- Search Bar (location text input)
- "Use Current Location" button
- Embedded Google Map View showing nearby lots
  - Pin color represents availability
- Bottom Navigation Bar:
  - Home, My Bookings, Profile

---

### 3.4 Parking Lot List
- List of nearby lots with:
  - Lot name, address
  - Slot availability (color badge)
  - Distance from current location
- Click navigates to Lot Details

---

### 3.5 Parking Lot Details
- Static data or API-integrated:
  - Slot availability
  - Rates
  - Operating hours
  - Reviews summary
- Button: "Book Slot"

---

### 3.6 Booking Screen
- Select:
  - Date and Time (start and end)
  - Duration auto-calculated
- Show:
  - Estimated cost
  - Booking summary
- Button: "Confirm Booking"
- On success: navigate to Booking Confirmation

---

### 3.7 Booking Confirmation
- Display:
  - Booking ID
  - Date, time, slot info
  - QR code (optional)
- Button: "Go to My Bookings"

---

### 3.8 My Bookings
- Tabs: Upcoming, Past
- List of reservations:
  - Date/time, location, status
- Click: View details / Cancel if applicable

---

### 3.9 Track & Navigate
- Open Google Maps with destination prefilled
- Show:
  - ETA
  - Current route from user location to lot

---

### 3.10 Payment Screen
- Fields:
  - Card/UPI input or redirect to payment provider
  - Payment method selection
- Confirmation on success/failure

---

### 3.11 Rate & Review Screen
- Rate using stars (1 to 5)
- Optional: text review, upload image
- Show average rating

---

### 3.12 Profile / Settings
- Display:
  - User Info
  - Saved payment methods (if supported)
- Actions:
  - Edit profile
  - Logout

---

## 4. Activity Flow/Navigation Flow

```mermaid
graph TD
    A[Splash Screen] --> B{Is Logged In?}
    B -- Yes --> C[Home Screen]
    B -- No --> D[Login Screen]
    D --> E[Registration Screen]
    C --> F[Map/List View]
    F --> G[Lot Details]
    G --> H[Booking Screen]
    H --> I[Booking Confirmation]
    I --> J[My Bookings]
    C --> J
    J --> K[Track & Navigate]
    J --> L[Payment Screen]
    J --> M[Rate & Review]
    C --> N[Profile/Settings]
