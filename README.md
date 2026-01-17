# SwiftPay Plus (Tunga) – Comprehensive README

---

## 1. Project Overview

**What the app does**: SwiftPay Plus (codenamed *Tunga*) is a mobile‑first financial management and payment application for iOS. It lets users:
- Link multiple banks and mobile‑money providers (Rwandan institutions).
- View an aggregated balance across all linked accounts.
- Send money to external recipients, top‑up between their own accounts, and request money.
- Generate and scan QR codes for fast payments.
- Browse transaction history, news, and notifications.

**Who it is for**: Individuals in Rwanda (or similar markets) who juggle several financial services and want a single dashboard to manage money.

**Problem it solves**: Managing multiple bank and mobile‑money apps is cumbersome – different logins, UI inconsistencies, and no unified view of total net worth. SwiftPay Plus aggregates accounts, provides seamless transfers, and offers QR‑based payments.

**Real‑world use cases**:
1. Salary lands in a bank account → top‑up MTN Mobile Money for daily expenses.
2. Pay a merchant via QR code.
3. Request money from a friend using a QR code.
4. Review total net worth across all institutions at a glance.

---

## 2. Tech Stack Breakdown

| Layer | Technology | Why Chosen |
|-------|------------|------------|
| **Backend** | **Swift 5.10+**, **Vapor 4**, **Fluent ORM**, **PostgreSQL** | Same language as iOS client (Swift) → reduces context‑switching, native async/await, strong type safety, ACID‑compliant relational DB for financial data. |
| **Authentication** | **JWT**, **Bcrypt** | Stateless token fits mobile, industry‑standard, secure password hashing with automatic salting. |
| **Frontend** | **SwiftUI**, **Combine**, **AVFoundation**, **CoreImage**, **LocalAuthentication** | Declarative UI, reactive data flow, native camera/QR handling, built‑in biometric support. |
| **Dev Ops** | **Docker Compose** (PostgreSQL), **Vapor CLI** | Easy local environment reproducibility. |

---

## 3. High‑Level Architecture

```
+-------------------+      HTTP/JSON (Bearer JWT)      +-------------------+
| iOS App (SwiftUI) | <----------------------------> | Vapor Backend (Swift) |
+-------------------+                                 +-------------------+
        |                                                   |
        | SwiftUI Views & Combine pipelines                |
        |   ↳ APIService → URLSession                     |
        |                                                   |
        |   ↳ QR generation (CoreImage)                    |
        |   ↳ QR scanning (AVFoundation)                  |
        |                                                   |
        |   ↳ Global AppState (auth token, user data)      |
        |                                                   |
        |   ↳ TransactionViewModel (state for flows)      |
        |                                                   |
        |   ↳ DesignSystem (colors, typography)           |
        |                                                   |
        v                                                   v
   PostgreSQL Database (users, institutions, linked_accounts, transactions, …)
```

**Data Flow example – Send Money**:
1. User taps *SEND* → `SendMoneyFlow` updates `TransactionViewModel`.
2. `APIService.sendMoney()` builds a POST `/transactions/send` with JWT.
3. Vapor routes to `TransactionController.sendMoney()`.
4. `SessionValidationMiddleware` validates JWT, injects `User`.
5. `TransactionService.performSend()` enforces limits, updates balances inside a DB transaction.
6. Response returns updated balances → `TransactionViewModel` updates UI.

**Authentication flow**: Signup → Bcrypt hash → store user. Login → verify password → issue JWT → stored in `UserDefaults`. Every request includes `Authorization: Bearer <token>`; middleware validates and attaches user.

---

## 4. Folder & File Structure

```
Tunga/
├── README.md                     # This file (user‑facing documentation)
├── README_COMPREHENSIVE.md       # Original detailed docs (source for this README)
├── .env                          # Environment variables (DB credentials, JWT secret)
├── Backend/
│   ├── Package.swift             # SwiftPM dependencies (Vapor, Fluent, etc.)
│   ├── docker-compose.yml        # PostgreSQL container definition
│   └── Sources/App/
│       ├── configure.swift       # DB, middleware, JWT setup
│       ├── routes.swift          # All API endpoint registrations
│       ├── Controllers/
│       │   ├── AuthController.swift
│       │   ├── InstitutionController.swift
│       │   ├── TransactionController.swift
│       │   └── NotificationController.swift
│       ├── Services/
│       │   └── TransactionService.swift
│       ├── Models/
│       │   ├── User.swift
│       │   ├── Institution.swift
│       │   ├── LinkedAccount.swift
│       │   ├── Transaction.swift
│       │   ├── QRPayload.swift
│       │   └── …
│       ├── Migrations/…
│       └── Middleware/
│           ├── SessionValidationMiddleware.swift
│           └── AppLoggerMiddleware.swift
└── Frontend/
    └── Stream/
        ├── AppEntry.swift          # @main entry point
        ├── AppState.swift          # Global observable state (auth, user, theme)
        ├── Core/
        │   ├── API/APIService.swift
        │   ├── API/DTOs.swift
        │   ├── DesignSystem.swift   # Colors, fonts, spacing (premium UI)
        │   └── Utils/QRScannerUtils.swift
        └── Flows/
            ├── Auth/…
            ├── Main/… (Dashboard, Activity, Cards, Settings)
            └── Actions/… (SendMoneyFlow, TopUpFlow, QRPaymentFlow, …)
```

**Key files**:
- `configure.swift` – sets up DB connection, registers migrations, adds JWT middleware.
- `routes.swift` – maps HTTP paths (`/auth/login`, `/transactions/send`, …) to controller methods.
- `TransactionService.swift` – business rules (limits, balance checks, atomic DB transaction).
- `AppState.swift` – holds auth token, current user, theme; drives navigation.
- `APIService.swift` – generic HTTP client, injects JWT, decodes snake_case JSON.
- `DesignSystem.swift` – defines the premium color palette, typography (Google Font *Inter*), and micro‑animations.

---

## 5. Feature‑by‑Feature Explanation

### 5.1 User Authentication
- **User flow**: Splash → Login/Signup → Dashboard.
- **Backend**: `AuthController` verifies Bcrypt password, issues JWT (`JWT_SECRET`).
- **Frontend**: `APIService.login()` stores token in `UserDefaults`; `AppState.isAuthenticated` toggles UI.
- **Edge cases**: empty fields, network failure, 401 → show error, auto‑logout on invalid token.

### 5.2 Link Institution
- **User flow**: Dashboard → “+” next to Institutions → pick bank/mobile‑money → set initial balance.
- **Backend**: `InstitutionController.linkInstitution` creates a `LinkedAccount` (unique `account_number`).
- **Frontend**: `LinkInstitutionFlow` fetches `/institutions/available`, posts link request, refreshes dashboard.
- **Edge cases**: duplicate linking (400), missing institution (404).

### 5.3 Send Money
- **User flow**: Dashboard → *SEND* → recipient → source account → amount → confirm.
- **Backend**: `TransactionService.performSend` validates amount ≥ 10 RWF, daily limit, balance, then atomically updates DB.
- **Frontend**: `SendMoneyFlow` stores steps in `TransactionViewModel`; on confirm calls `APIService.sendMoney()`.
- **Edge cases**: amount < 10, insufficient balance, daily limit exceeded, frozen account.

### 5.4 QR Code Payments
- **Generate**: Institution detail → *REQUEST* → backend creates `QRPayload` (type, amount, timestamps) and signs with HMAC‑SHA256 (`QR_SECRET`). Frontend renders QR via `CoreImage`.
- **Scan**: Dashboard → *SCAN* → `QRScannerView` uses AVFoundation, decodes JSON, verifies signature, then routes to appropriate flow (send/top‑up/request).
- **Backend verification**: `QRPayload.verify(secret:)` recomputes HMAC, checks timestamp.
- **Edge cases**: malformed QR, signature mismatch, expired QR, missing source account for request.

### 5.5 Notifications & News
- **Backend**: `NotificationController` creates `Notification` records; `NewsController` serves static news articles.
- **Frontend**: `AppState` holds arrays of `Notification` and `NewsArticle`; UI displays badge counts.

---

## 6. Database Design

### Tables Overview
- **users** – core user data, Bcrypt password hash, token version.
- **institutions** – static list of banks/mobile‑money providers.
- **linked_accounts** – join table (`user_id` ↔ `institution_id`) with generated `account_number`, balance, limits, freeze flag.
- **transactions** – records of every money movement; negative amount for outgoing, positive for incoming.
- **news_articles**, **notifications** – auxiliary content.

### Relationships
```
User (1) ──< (N) LinkedAccount
User (1) ──< (N) Transaction
User (1) ──< (N) Notification
Institution (1) ──< (N) LinkedAccount
```

### Example Record (LinkedAccount)
```json
{
  "id": "linked-001",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "institution_id": "inst-001",
  "account_number": "STREAM-4829-7361",
  "balance": 250000.0,
  "is_frozen": false,
  "daily_limit": 2000000.0,
  "monthly_limit": 10000000.0
}
```

---

## 7. Authentication & Security

- **Signup**: validates email, hashes password with Bcrypt (cost 12), stores user, gives starter balance.
- **Login**: verifies password, issues JWT (`HS256`) containing `sub`, `name`, `email`, `tokenVersion`.
- **JWT handling**: stored in `UserDefaults`; every request adds `Authorization: Bearer <token>`.
- **SessionValidationMiddleware**: decodes JWT, checks signature with `JWT_SECRET`, loads user, verifies `tokenVersion` (allows forced logout).
- **Password hashing**: Bcrypt provides per‑hash salt, resistant to brute‑force.
- **Future hardening**: add `exp` claim for token expiry, rotate `JWT_SECRET`, enable refresh tokens.

---

## 8. Environment Configuration

| Variable | Purpose | Required? |
|----------|---------|-----------|
| `POSTGRES_HOST` | PostgreSQL host (Docker service name) | Yes |
| `POSTGRES_PORT` | PostgreSQL port (default 5432) | Yes |
| `POSTGRES_DB` | Database name | Yes |
| `POSTGRES_USER` | DB username | Yes |
| `POSTGRES_PASSWORD` | DB password | Yes |
| `JWT_SECRET` | HMAC key for signing JWTs | Yes |
| `QR_SECRET` | HMAC key for QR payload signatures | Yes |
| `APP_PORT` | Port the Vapor server listens on (default 8080) | Optional |

**Missing variable behavior**: Vapor will abort startup with a clear error message; the app cannot run without DB credentials or secrets.

**Example `.env`** (do **not** commit to repo):
```
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=swiftpay
POSTGRES_USER=swiftpay_user
POSTGRES_PASSWORD=super_secret_pw
JWT_SECRET=very_long_random_string
QR_SECRET=another_random_secret
```

---

## 9. Local Setup Guide (Beginner Friendly)

1. **Prerequisites**
   - Xcode 15+ (macOS 14+)
   - Homebrew (for Docker) – `brew install docker docker-compose`
   - Swift 5.10 (bundled with Xcode)
2. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd Tunga
   ```
3. **Backend**
   - Copy `.env.example` → `.env` and fill in values.
   - Start PostgreSQL container:
     ```bash
     docker compose up -d
     ```
   - Build & run Vapor server:
     ```bash
     swift run Run
     # or use Xcode scheme "App"
     ```
   - The API will be reachable at `http://localhost:8080`.
4. **Frontend (iOS app)**
   - Open `Tunga.xcodeproj` (or the `Stream` folder) in Xcode.
   - Select a simulator (iPhone 14) and hit **Run**.
   - The app will automatically hit the local backend (`localhost:8080`). If you run on a physical device, replace `localhost` with your machine’s IP.
5. **Common errors & fixes**
   - *“Could not connect to PostgreSQL”*: ensure Docker container is running, ports are not blocked, and `.env` values match.
   - *“JWT secret not set”*: double‑check `.env` contains `JWT_SECRET`.
   - *Build failures*: run `swift package clean` then `swift build` to refresh dependencies.

---

## 10. How to Modify or Extend the App

- **Add a new backend endpoint**
  1. Create a new controller method in `Sources/App/Controllers/`.
  2. Register the route in `routes.swift`.
  3. Add any needed DTOs in `Models/` and migrations if persisting new data.
  4. Write unit tests under `Tests/` (Vapor’s XCTests).
- **Add a new UI screen**
  1. Add a SwiftUI view under `Frontend/Stream/Flows/…`.
  2. Hook it into the navigation (e.g., add a tab in `MainContainerView.swift` or push from an existing flow).
  3. Use `APIService` for network calls; inject the JWT automatically.
  4. Update `DesignSystem.swift` if you need new colors or typography.
- **Change business logic**
  - Locate the relevant service (e.g., `TransactionService.swift`) and modify the method. Keep validation rules together; add comments explaining why.
- **Safety tips**
  - Run the app locally after each change.
  - Keep migrations reversible.
  - Write/adjust tests to cover new behavior.

---

## 11. Known Issues / Code Smells

- **Hard‑coded strings** (e.g., endpoint paths) are scattered; consider centralising in an enum.
- **No token expiry** – JWTs never expire; could be a security risk.
- **Limited error handling** in `APIService` – many backend errors surface as generic alerts.
- **Database transaction nesting** – some service methods start a transaction but also call other methods that start their own; could lead to deadlocks.
- **UI duplication** – several flows repeat similar step‑by‑step UI; could be abstracted into a reusable wizard component.
- **Missing unit tests** for QR payload verification edge cases.

*Suggested improvements*: add `exp` claim to JWT, consolidate API paths, refactor wizard UI, increase test coverage.

---

## 12. Mental Model Summary

> **If you remember only one thing about SwiftPay Plus, remember this:**
> 
> It is a **Swift‑native, full‑stack mobile payment platform** where the **frontend (SwiftUI) talks to a **Vapor‑based Swift backend** via **JWT‑protected JSON APIs**. All financial data lives in **PostgreSQL**, and the app’s core value is **aggregating multiple Rwandan financial institutions** into a single, beautiful UI that supports **QR‑based payments**, **instant transfers**, and **real‑time balance updates**.

---

*End of README*
