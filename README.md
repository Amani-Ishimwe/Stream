# Stream 🌊

Stream is a secure, real-time mobile payment platform that allows users to aggregate balances from multiple financial institutions, perform transfers, and manage their linked accounts.

## 🚀 Overview

Stream connects disconnected financial worlds (Banks & Mobile Money) into a single, cohesive interface. It does not hold money itself but acts as a secure orchestration layer.

### Key Features
*   **Unified Dashboard**: View real-time aggregated balance from all linked accounts.
*   **Atomic Transactions**: Perform "Top-Ups" (Transfers) between your own linked accounts (e.g., MTN MoMo -> I&M Bank).
*   **Send & Request**: Send money to contacts or request payments via QR.
*   **Card Management**: View details and freeze/unfreeze your virtual cards instantly (synced with backend).
*   **Secure**: JWT Authentication and biometric-ready UI.

## 🏗 Architecture

The project follows a **Client-Server** architecture.

### 📱 Frontend (iOS)
*   **Language**: Swift (SwiftUI)
*   **Architecture**: MVVM (Model-View-ViewModel)
*   **Design System**: Custom "Stream" aesthetic (Deep Blue #001F3F, Soft Beige #F5F5DC, Accent Gold #FFD700).
*   **Networking**: `APIService` (Async/Await) using `URLSession`.

### 🖥 Backend (Server)
*   **Framework**: Vapor 4 (Swift)
*   **Database**: PostgreSQL (Production) / SQLite (Development)
*   **ORM**: Fluent
*   **Auth**: JWT (JSON Web Tokens)
*   **Models**:
    *   `User`: The account holder.
    *   `Institution`: Bank or Mobile Money provider details.
    *   `LinkedAccount`: The user's specific account at an institution (stores persistent balance, freeze status).
    *   `Transaction`: Ledger of all moves.

## 🛠 Setup & Running

### Prerequisites
*   macOS with Xcode 14+
*   Swift 5.9+

### 1. Backend
1.  Navigate to the backend directory:
    ```bash
    cd Backend
    ```
2.  Run the server (this will migrate and seed data automatically):
    ```bash
    swift run
    ```
    *The server runs on `http://127.0.0.1:8080`.*

### 2. Frontend (iOS App)
1.  Open `Frontend/Tunga/Tunga.xcodeproj` in Xcode.
2.  Ensure the Simulator is selected (e.g., iPhone 15 Pro).
3.  Build and Run (`Cmd + R`).

## 🧪 Testing the Flow

1.  **Login**: Use the seeded demo account:
    *   **Email**: `demo@stream.rw`
    *   **Password**: `password`
2.  **Dashboard**: You will see the total balance from seeded institutions (MTN MoMo: 54k, Bank of Kigali: 1.25M).
3.  **Transfers**:
    *   Tap **Top-Up**.
    *   Select "Bank of Kigali" as Source.
    *   Select "MTN MoMo" as Destination.
    *   Enter Amount (e.g., 5000).
    *   Confirm.
    *   **Check Dashboard**: Balances update immediately (MoMo +5000, BK -5000).
4.  **Cards**:
    *   Go to **Cards** tab.
    *   Tap **Freeze Card**.
    *   Status updates to "FROZEN" (persisted in backend).

## 🔒 Security Notes
*   **No PIN Storage**: PINs are never stored. The backend manages authenticated sessions via JWT.
*   **Atomic Operations**: Financial transactions use database transaction blocks to ensure money is never duplicated or lost.
*   **Audit Trail**: All actions are recorded in the `Transaction` ledger.

## 🗺 Roadmap
*   Physical Card Ordering integration.
*   Push Notifications via APNS.
*   Integration with live Institution APIs (aggregators).

---
*Built with ❤️ by the Stream Engineering Team.*
