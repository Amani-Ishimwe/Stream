# SwiftPay Plus (Tunga) - Complete Technical Documentation

> **A comprehensive guide to understanding, running, and extending this mobile payment application**

---

## 1. Project Overview

### What the App Does

SwiftPay Plus (codenamed "Tunga") is a **mobile-first financial management and payment application** built for iOS. It allows users to:

- Link multiple financial institutions (banks and mobile money providers)
- View aggregated balances across all linked accounts
- Send money to external recipients
- Transfer funds between their own linked accounts ("Top-Up")
- Request money from others
- Generate and scan QR codes for payments
- Track transaction history with detailed filtering
- Manage account limits and freeze/unfreeze accounts

### Who It's For

- **Primary Users**: Individuals in Rwanda who use multiple financial services (banks like Bank of Kigali, I&M Bank, and mobile money like MTN, Airtel)
- **Use Case**: People who want a unified dashboard to manage money across different institutions without switching between multiple apps

### The Main Problem It Solves

**Problem**: In Rwanda (and many African countries), people often have accounts with multiple banks and mobile money providers. Managing these separately is cumbersome - you need different apps, different logins, and can't easily see your total financial picture.

**Solution**: SwiftPay Plus aggregates all your accounts in one place, lets you move money between them, and provides a unified transaction history.

### Real-World Use Cases

1. **Salary Distribution**: Receive salary in Bank of Kigali, then top-up your MTN Mobile Money for daily expenses
2. **Bill Payments**: Send money from your I&M account to pay a merchant
3. **P2P Transfers**: Generate a QR code for someone to pay you directly into your preferred account
4. **Financial Overview**: See your total net worth across all institutions at a glance

---

## 2. Tech Stack Breakdown

### Backend

| Technology | Version | Purpose | Why Chosen |
|------------|---------|---------|------------|
| **Swift** | 5.10+ | Programming language | Native performance, type safety, modern concurrency |
| **Vapor** | 4.100.0+ | Web framework | Swift-native, async/await support, excellent for building REST APIs |
| **Fluent** | 4.9.0+ | ORM (Object-Relational Mapping) | Database abstraction, type-safe queries, migrations |
| **PostgreSQL** | Latest | Relational database | ACID compliance, robust for financial data, excellent JSON support |
| **FluentPostgresDriver** | 2.8.0+ | Postgres adapter for Fluent | Connects Fluent ORM to PostgreSQL |
| **JWT** | 4.2.0+ | Authentication tokens | Stateless auth, mobile-friendly, industry standard |
| **Bcrypt** | Built-in | Password hashing | Secure password storage with salt |

**Why Vapor?**
- Written in Swift, so the same language as the iOS app (reduces context switching for full-stack Swift developers)
- Modern async/await makes it easy to write non-blocking code
- Strong type system prevents many runtime errors
- Growing ecosystem

### Frontend

| Technology | Purpose | Why Chosen |
|------------|---------|------------|
| **SwiftUI** | UI framework | Declarative UI, native iOS, reactive updates |
| **Combine** | Reactive programming | State management, async data flows |
| **AVFoundation** | Camera/QR scanning | Native camera access for QR code scanning |
| **CoreImage** | QR code generation | Generate QR codes from data |
| **LocalAuthentication** | Biometrics | Face ID / Touch ID for secure access |

**Why SwiftUI?**
- Modern, declarative approach (easier to reason about UI state)
- Automatic UI updates when data changes
- Native performance and iOS integration
- Less boilerplate than UIKit

### Database

- **PostgreSQL**: Chosen for ACID transactions (critical for financial data), excellent performance, and JSON field support

---

## 3. High-Level Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS App (SwiftUI)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Auth Views   │  │ Dashboard    │  │ Transaction  │      │
│  │              │  │ Views        │  │ Flows        │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │   APIService   │                        │
│                    │  (HTTP Client) │                        │
│                    └───────┬────────┘                        │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │   AppState     │                        │
│                    │ (Global State) │                        │
│                    └────────────────┘                        │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTP/JSON
                          │ (Bearer Token Auth)
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                  Vapor Backend (Swift)                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                     routes.swift                      │   │
│  │              (Route Registration)                     │   │
│  └────┬──────────────────┬──────────────────┬───────────┘   │
│       │                  │                  │                │
│  ┌────▼────────┐  ┌──────▼──────┐  ┌───────▼────────┐      │
│  │   Auth      │  │ Institution │  │  Transaction   │      │
│  │ Controller  │  │ Controller  │  │  Controller    │      │
│  └────┬────────┘  └──────┬──────┘  └───────┬────────┘      │
│       │                  │                  │                │
│       │                  │          ┌───────▼────────┐      │
│       │                  │          │  Transaction   │      │
│       │                  │          │    Service     │      │
│       │                  │          │ (Business Logic)│     │
│       │                  │          └───────┬────────┘      │
│       │                  │                  │                │
│  ┌────▼──────────────────▼──────────────────▼────────┐      │
│  │              Fluent ORM (Database Layer)          │      │
│  └────────────────────────┬──────────────────────────┘      │
└───────────────────────────┼──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│                    PostgreSQL Database                        │
│  ┌─────────┐ ┌──────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │  users  │ │ institutions │ │ linked_     │ │transactions││
│  │         │ │              │ │ accounts    │ │            ││
│  └─────────┘ └──────────────┘ └─────────────┘ └──────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow: Example Transaction

Let's trace a "Send Money" operation:

1. **User Action**: User taps "SEND" on Dashboard → Opens `SendMoneyFlow`
2. **Frontend Flow**:
   - User enters recipient phone number, selects source account, enters amount
   - User confirms transaction
   - `TransactionViewModel` calls `APIService.sendMoney()`
3. **API Call**:
   - `APIService` creates HTTP POST to `/transactions/send`
   - Includes Bearer token in Authorization header
   - Sends JSON body with `sourceInstitutionId`, `amount`, `recipient`
4. **Backend Routing**:
   - Vapor receives request at `routes.swift`
   - Routes to `TransactionController.sendMoney()`
5. **Middleware**:
   - `SessionValidationMiddleware` validates JWT token
   - Extracts user from token, attaches to request
6. **Controller**:
   - `TransactionController` decodes request body
   - Calls `TransactionService.performSend()`
7. **Business Logic** (`TransactionService`):
   - Validates minimum amount (10 RWF)
   - Fetches source `LinkedAccount` from database
   - Checks if account is frozen
   - Calculates daily spending limit
   - Checks if user has sufficient balance
   - **Database Transaction** (atomic):
     - Deducts amount from source account balance
     - Creates `Transaction` record
     - Saves both to database
   - Returns `TransactionResult` with updated balances
8. **Response**:
   - Controller wraps result in `StreamResponse`
   - Vapor serializes to JSON (snake_case keys, ISO8601 dates)
   - Returns HTTP 200 with transaction data
9. **Frontend Update**:
   - `APIService` receives response, decodes to Swift types
   - `TransactionViewModel` updates local state
   - SwiftUI automatically re-renders UI with new balance
   - Shows success message

### Authentication Flow

**Signup**:
1. User enters name, email, phone, password, PIN
2. Frontend → `POST /auth/signup`
3. Backend hashes password with Bcrypt
4. Creates `User` record with 100,000 RWF starting balance
5. Returns success message

**Login**:
1. User enters email + password
2. Frontend → `POST /auth/login`
3. Backend finds user by email
4. Verifies password with Bcrypt
5. Creates JWT with payload: `{ sub: userId, name, email, tokenVersion }`
6. Signs JWT with `JWT_SECRET`
7. Returns token to frontend
8. Frontend stores token in `UserDefaults`
9. All subsequent requests include `Authorization: Bearer <token>`

**Session Validation**:
- Every protected route uses `SessionValidationMiddleware`
- Middleware decodes JWT, verifies signature
- Extracts user ID, loads `User` from database
- Attaches user to request for controllers to use
- If token invalid/expired → returns 401 Unauthorized

---

## 4. Folder & File Structure

### Backend Structure

```
Backend/
├── Package.swift              # Swift Package Manager config (dependencies)
├── .env                       # Environment variables (DB credentials, secrets)
├── docker-compose.yml         # PostgreSQL container setup
└── Sources/
    └── App/
        ├── configure.swift    # App configuration (DB, middleware, JWT)
        ├── routes.swift       # Route registration
        ├── SeedData.swift     # Database seeding (Rwandan banks/mobile money)
        ├── Controllers/       # HTTP request handlers
        │   ├── AuthController.swift
        │   ├── UserController.swift
        │   ├── InstitutionController.swift
        │   ├── TransactionController.swift
        │   ├── NewsController.swift
        │   └── NotificationController.swift
        ├── Services/          # Business logic layer
        │   └── TransactionService.swift
        ├── Models/            # Database models (Fluent)
        │   ├── User.swift
        │   ├── Institution.swift
        │   ├── LinkedAccount.swift
        │   ├── Transaction.swift
        │   ├── NewsArticle.swift
        │   ├── Notification.swift
        │   ├── QRPayload.swift
        │   └── StreamResponse.swift
        ├── Migrations/        # Database schema changes
        │   ├── CreateUser.swift
        │   ├── CreateInstitution.swift
        │   ├── CreateLinkedAccount.swift
        │   ├── CreateTransaction.swift
        │   └── ...
        └── Middleware/        # Request interceptors
            ├── SessionValidationMiddleware.swift
            └── AppLoggerMiddleware.swift
```

#### Key Backend Files Explained

**`configure.swift`**:
- **What**: App initialization and configuration
- **Why**: Central place to set up database, middleware, JWT signing
- **Key Actions**:
  - Connects to PostgreSQL using env vars
  - Registers all migrations
  - Runs auto-migration on startup
  - Seeds initial data (Rwandan institutions)
  - Configures JSON encoding/decoding (snake_case, ISO8601)

**`routes.swift`**:
- **What**: Maps HTTP paths to controller methods
- **Why**: Single source of truth for all API endpoints
- **Example**: `POST /auth/login` → `AuthController.login()`

**`TransactionService.swift`**:
- **What**: Core business logic for all transaction types
- **Why**: Separates business rules from HTTP handling (controllers)
- **Methods**:
  - `performSend()`: External transfer
  - `performTopUp()`: Internal transfer between user's accounts
  - `performRequest()`: Receive money
  - `performQRTransaction()`: Dispatcher for QR-based transactions
- **Critical Logic**:
  - Daily/monthly limit enforcement
  - Balance validation
  - Atomic database transactions (rollback on error)

**`SessionValidationMiddleware.swift`**:
- **What**: JWT token validator
- **Why**: Protects routes, ensures only authenticated users access data
- **How**: Decodes JWT, verifies signature, loads user, attaches to request

### Frontend Structure

```
Frontend/Stream/
├── AppEntry.swift             # App entry point (@main)
├── AppState.swift             # Global app state (auth, user, theme)
├── Core/                      # Shared utilities and services
│   ├── API/
│   │   ├── APIService.swift   # HTTP client (all backend calls)
│   │   └── DTOs.swift         # Data Transfer Objects
│   ├── Models/
│   │   └── Models.swift       # Frontend data models
│   ├── DesignSystem.swift     # Colors, typography, spacing
│   └── Utils/
│       └── QRScannerUtils.swift
└── Flows/                     # Feature-based UI organization
    ├── StreamRootView.swift   # Root navigation (splash → auth → main)
    ├── Auth/                  # Authentication screens
    │   ├── LoginView.swift
    │   ├── SignupView.swift
    │   └── BiometricSetupView.swift
    ├── Main/                  # Main app screens
    │   ├── MainContainerView.swift  # Tab bar container
    │   ├── DashboardView.swift      # Home screen
    │   ├── ActivityView.swift       # Transaction history
    │   ├── CardsView.swift          # Virtual card view
    │   ├── SettingsView.swift       # User settings
    │   ├── QRScannerView.swift      # QR code scanner
    │   ├── Institutions/
    │   │   └── InstitutionDetailView.swift
    │   └── Transactions/
    │       └── TransactionDetailView.swift
    └── Actions/               # Transaction flows
        ├── SendMoneyFlow.swift
        ├── TopUpFlow.swift
        ├── RequestMoneyFlow.swift
        ├── LinkInstitutionFlow.swift
        ├── QRPaymentFlow.swift
        └── TransactionViewModel.swift
```

#### Key Frontend Files Explained

**`AppState.swift`**:
- **What**: Global observable state
- **Why**: Shares auth status, user profile, theme across entire app
- **Properties**:
  - `isAuthenticated`: Controls navigation (login vs main app)
  - `currentUser`: User profile data
  - `token`: JWT stored in UserDefaults
  - `colorSchemeOverride`: Dark/light mode preference

**`APIService.swift`**:
- **What**: Singleton HTTP client
- **Why**: Centralized API communication, handles auth headers, error handling
- **Key Features**:
  - Generic `request<T>()` method for all API calls
  - Automatic JWT token injection
  - Snake_case ↔ camelCase conversion
  - ISO8601 date handling
  - Error mapping (401 → logout, etc.)

**`MainContainerView.swift`**:
- **What**: Tab bar container with 5 tabs
- **Why**: Main navigation structure after login
- **Tabs**: Home, Activity, Send, Cards, Settings

**`TransactionViewModel.swift`**:
- **What**: Shared state for transaction flows
- **Why**: Multi-step flows (recipient → source → amount → confirm) need persistent state
- **Properties**: `selectedSource`, `selectedDestination`, `amount`, `recipient`, `metadata`

---

## 5. Feature-by-Feature Explanation

### Feature 1: User Authentication

**User Flow**:
1. Open app → Splash screen → Login screen
2. Enter email + password → Tap "LOGIN"
3. On success → Navigate to Dashboard

**Backend Logic** (`AuthController.login`):
```swift
1. Decode LoginRequest from JSON body
2. Query database for user by email
3. If not found → throw 401 "Invalid email or password"
4. Verify password with Bcrypt.verify()
5. If incorrect → throw 401
6. Create UserPayload with user ID, name, email, tokenVersion
7. Sign JWT with JWT_SECRET
8. Return StreamResponse with token
```

**Frontend Logic** (`LoginView`):
```swift
1. User taps login button
2. Call APIService.login(email, password)
3. On success:
   - Store token in UserDefaults
   - Fetch user profile with token
   - Update AppState.login(user, token)
   - AppState.isAuthenticated = true
   - SwiftUI navigates to MainContainerView
4. On error:
   - Show error alert
```

**Edge Cases**:
- Empty email/password → Show validation error
- Network failure → Show "Check your connection"
- 401 response → Show "Invalid credentials"
- Token stored but invalid → Auto-logout on first API call

### Feature 2: Link Institution

**User Flow**:
1. Dashboard → Tap "+" next to INSTITUTIONS
2. See list of available banks/mobile money
3. Select one → Enter initial balance → Confirm
4. Institution appears in dashboard

**Backend Logic** (`InstitutionController.linkInstitution`):
```swift
1. Decode LinkRequest (institutionId, balance)
2. Check if user already linked this institution
3. If yes → throw 400 "Already linked"
4. Verify institution exists in database
5. Create LinkedAccount:
   - Generate account number: "STREAM-XXXX-XXXX"
   - Set balance from input (or 0)
   - Set default limits (daily: 2M RWF, monthly: 10M RWF)
   - isFrozen = false
6. Save to database
7. Return InstitutionDTO (merged data from Institution + LinkedAccount)
```

**Frontend Logic** (`LinkInstitutionFlow`):
```swift
1. Fetch available institutions from /institutions/available
2. Display in list
3. User selects one
4. Show balance input sheet
5. Call APIService.linkInstitution(id, balance)
6. On success:
   - Dismiss sheet
   - Refresh dashboard (re-fetch institutions)
   - Show success message
```

**Important Functions**:
- `InstitutionDTO.init(linked:)`: Merges `Institution` (static data) with `LinkedAccount` (user-specific data)

**Edge Cases**:
- User tries to link same institution twice → Backend prevents with 400 error
- Institution doesn't exist → Backend returns 404

### Feature 3: Send Money

**User Flow**:
1. Dashboard → Tap "SEND" quick action
2. **Step 1**: Choose transfer type (PHONE or BANK), enter recipient
3. **Step 2**: Select funding source (linked account)
4. **Step 3**: Enter amount
5. **Step 4**: Review details → Confirm
6. See success screen with transaction details

**Backend Logic** (`TransactionService.performSend`):
```swift
1. Validate amount >= 10 RWF
2. Fetch source LinkedAccount for user
3. Check if account is frozen → throw 403
4. Calculate daily spending:
   - Get all transactions from source account since midnight
   - Sum absolute amounts
5. Check if (dailySpent + amount) > dailyLimit → throw 403
6. Check if balance >= amount → throw 400 "Insufficient funds"
7. Start database transaction:
   a. Deduct amount from source account balance
   b. Save updated balance
   c. Create Transaction record:
      - type: "SEND"
      - amount: -amount (negative for outgoing)
      - counterparty: recipient
      - status: "Completed"
      - sourceInstitutionID: source account
      - destinationInstitutionID: null (external)
   d. Save transaction
8. Commit transaction (or rollback on error)
9. Return TransactionResult with updated balance
```

**Frontend Logic** (`SendMoneyFlow`):
```swift
1. Multi-step wizard with state in TransactionViewModel
2. Step 1 (RecipientStep):
   - Validate phone number length (10+ digits) or account number (8+ digits)
   - Store in viewModel.recipient
3. Step 2 (SourceSelectionStep):
   - Fetch user's linked institutions
   - User selects one → viewModel.selectedSource
4. Step 3 (AmountStep):
   - User enters amount → viewModel.amount
5. Step 4 (ConfirmStep):
   - Display summary
   - On confirm → Call APIService.sendMoney()
   - On success:
     - Show success animation
     - Update local balances from response.updatedBalances
     - Dismiss flow
```

**Important Functions**:
- `TransactionService.getSpentAmount()`: Calculates spending in time range for limit enforcement
- `TransactionViewModel.sendMoney()`: Orchestrates API call and error handling

**Edge Cases**:
- Amount < 10 RWF → Backend rejects with 400
- Insufficient balance → Backend rejects with 400
- Daily limit exceeded → Backend rejects with 403 (shows remaining limit)
- Account frozen → Backend rejects with 403
- Network error during transaction → Database rollback ensures no partial state

### Feature 4: QR Code Payments

**User Flow (Generate)**:
1. Institution Detail → Tap "REQUEST" → Card flips to show QR code
2. Backend generates signed QR payload
3. QR code displayed with account number
4. User can save to photos

**User Flow (Scan)**:
1. Dashboard → Tap "SCAN" → Camera opens
2. Scan QR code
3. Decode payload, verify signature
4. Show payment confirmation sheet
5. Select source account → Confirm
6. Transaction executed

**Backend Logic** (`QRPayload` model):
```swift
// QR Payload Structure
{
  "type": "send" | "request" | "topup",
  "amount": 5000.0,
  "sourceId": "uuid" (optional),
  "destinationId": "uuid" (optional),
  "timestamp": "2026-01-17T19:00:00Z",
  "signature": "hmac-sha256-hash"
}

// Generation
1. Create QRPayload with type, amount, IDs
2. Set timestamp = now
3. Calculate HMAC-SHA256 signature:
   - Concatenate: type + amount + sourceId + destinationId + timestamp
   - Sign with QR_SECRET
4. Return payload to frontend

// Verification (on scan)
1. Receive QRPayload from frontend
2. Recalculate signature with same algorithm
3. Compare signatures → if mismatch, throw 400 "Invalid QR"
4. Check timestamp (could add expiry check)
5. Route to appropriate transaction type
```

**Frontend Logic** (`QRScannerView`):
```swift
1. Request camera permission
2. Use AVFoundation to capture video
3. Detect QR code in frame
4. Extract string data
5. Try multiple JSON decoding strategies:
   - ISO8601 dates + default keys
   - Seconds since 1970 + default keys
   - ISO8601 + snake_case keys
   - Seconds since 1970 + snake_case keys
6. If decoded successfully:
   - Dismiss scanner
   - Show QRPaymentFlow with payload
7. If decode fails:
   - Show error alert
```

**Important Functions**:
- `QRPayload.sign(secret:)`: Generates HMAC signature
- `QRPayload.verify(secret:)`: Validates signature
- `QRScannerUtils.detectQRCode(from:)`: Extracts QR from UIImage (for gallery scanning)

**Edge Cases**:
- Invalid QR format → Show "INCORRECT FORMAT" error
- Expired QR (if implemented) → Backend rejects
- QR for REQUEST type but no source selected → Prompt user to select account
- Camera permission denied → Show settings prompt

---

## 6. Database Design

### Tables Overview

```
users
  ├── id (UUID, PK)
  ├── name (String)
  ├── email (String, unique)
  ├── phone (String)
  ├── pin (String) - 6-digit PIN for transactions
  ├── password_hash (String) - Bcrypt hashed
  ├── balance (Double) - Legacy field, not actively used
  ├── avatar_url (String, optional)
  └── token_version (Int) - For invalidating JWTs

institutions
  ├── id (UUID, PK)
  ├── name (String) - e.g., "Bank of Kigali"
  ├── type (String) - "BANK" or "MOBILE_MONEY"
  ├── icon_symbol (String) - SF Symbol name for iOS
  ├── primary_color_hex (String) - Brand color
  └── is_active (Bool) - Can be linked by users

linked_accounts
  ├── id (UUID, PK)
  ├── user_id (UUID, FK → users)
  ├── institution_id (UUID, FK → institutions)
  ├── account_number (String) - Generated: "STREAM-XXXX-XXXX"
  ├── balance (Double) - User's balance at this institution
  ├── last_synced (Date) - Last update timestamp
  ├── is_frozen (Bool) - User can freeze account
  ├── daily_limit (Double) - Max spending per day
  └── monthly_limit (Double) - Max spending per month

transactions
  ├── id (UUID, PK)
  ├── user_id (UUID, FK → users)
  ├── type (String) - "SEND", "RECEIVE", "TOPUP"
  ├── amount (Double) - Negative for outgoing, positive for incoming
  ├── description (String, optional)
  ├── counterparty (String, optional) - Recipient/sender name
  ├── status (String) - "Completed", "Pending", "Failed"
  ├── source_institution_id (UUID, optional, FK → institutions)
  ├── destination_institution_id (UUID, optional, FK → institutions)
  ├── failure_reason (String, optional)
  ├── metadata (JSON, optional) - Additional data
  └── created_at (Timestamp)

news_articles
  ├── id (UUID, PK)
  ├── title (String)
  ├── summary (String)
  ├── image_url (String)
  └── published_at (Date)

notifications
  ├── id (UUID, PK)
  ├── user_id (UUID, FK → users)
  ├── title (String)
  ├── message (String)
  ├── is_read (Bool)
  └── created_at (Timestamp)
```

### Relationships

```
User (1) ──< (N) LinkedAccount
User (1) ──< (N) Transaction
User (1) ──< (N) Notification
Institution (1) ──< (N) LinkedAccount
```

**Key Points**:
- `LinkedAccount` is the join table between `User` and `Institution`
- Each user can link the same institution only once
- `Transaction` can have source and/or destination institutions (or neither for external transfers)

### Example Records

**User**:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Amani Ishimwe",
  "email": "amani@example.com",
  "phone": "+250788123456",
  "pin": "123456",
  "password_hash": "$2b$12$...",
  "balance": 100000.0,
  "avatar_url": null,
  "token_version": 1
}
```

**Institution**:
```json
{
  "id": "inst-001",
  "name": "Bank of Kigali",
  "type": "BANK",
  "icon_symbol": "building.columns",
  "primary_color_hex": "#0066CC",
  "is_active": true
}
```

**LinkedAccount**:
```json
{
  "id": "linked-001",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "institution_id": "inst-001",
  "account_number": "STREAM-4829-7361",
  "balance": 250000.0,
  "last_synced": "2026-01-17T19:00:00Z",
  "is_frozen": false,
  "daily_limit": 2000000.0,
  "monthly_limit": 10000000.0
}
```

**Transaction**:
```json
{
  "id": "tx-001",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "type": "SEND",
  "amount": -5000.0,
  "description": "Transfer to 0788999888",
  "counterparty": "0788999888",
  "status": "Completed",
  "source_institution_id": "inst-001",
  "destination_institution_id": null,
  "failure_reason": null,
  "metadata": {"type": "PHONE"},
  "created_at": "2026-01-17T18:30:00Z"
}
```

---

## 7. Authentication & Security

### How Login/Signup Works

**Signup Process**:
1. User submits: name, email, phone, password, PIN
2. Backend validates email format (Vapor's built-in validation)
3. Checks if email already exists → reject if duplicate
4. Hashes password with Bcrypt (cost factor: 12 rounds)
5. Stores user with hashed password (plaintext password never stored)
6. Gives user 100,000 RWF starting balance
7. Returns success (no auto-login, user must login separately)

**Login Process**:
1. User submits: email, password
2. Backend finds user by email
3. Verifies password: `Bcrypt.verify(plaintext, hashed)`
4. If valid, creates JWT payload:
   ```json
   {
     "sub": "user-uuid",
     "name": "Amani Ishimwe",
     "email": "amani@example.com",
     "tokenVersion": 1
   }
   ```
5. Signs JWT with HS256 algorithm using `JWT_SECRET`
6. Returns token to frontend
7. Frontend stores in `UserDefaults` (key: `stream_auth_token`)

### Token/Session Handling

**JWT Structure**:
- **Header**: `{ "alg": "HS256", "typ": "JWT" }`
- **Payload**: User data (sub, name, email, tokenVersion)
- **Signature**: HMAC-SHA256(header + payload, JWT_SECRET)

**Token Lifecycle**:
1. **Creation**: On successful login
2. **Storage**: Frontend stores in UserDefaults (persists across app launches)
3. **Usage**: Included in every API request: `Authorization: Bearer <token>`
4. **Validation**: `SessionValidationMiddleware` verifies on each request
5. **Invalidation**: 
   - User logout → Frontend deletes from UserDefaults
   - Token version mismatch → Backend rejects (allows force logout all sessions)
   - No expiration implemented (could be added with `exp` claim)

**Session Validation Flow**:
```swift
1. Middleware intercepts request
2. Extract "Authorization" header
3. Remove "Bearer " prefix
4. Decode JWT (verify signature with JWT_SECRET)
5. Extract user ID from "sub" claim
6. Query database for user
7. Check tokenVersion matches
8. Attach user to request.auth
9. Pass to controller
```

### Password Hashing

**Algorithm**: Bcrypt
**Why Bcrypt?**
- Designed for passwords (slow by design, prevents brute force)
- Automatic salting (each hash is unique even for same password)
- Adaptive (can increase cost factor as computers get faster)

**Process**:
```swift
// Signup
let hash = try Bcrypt.hash("user_password") 
// Result: "$2b$12$randomsalt$hashedpassword"

// Login
let isValid = try Bcrypt.verify("user_password", created: hash)
// Returns true/false
```

### Role-Based Access Control

**Current Implementation**: None (all authenticated users have same permissions)

**What's Missing**:
- No admin vs regular user distinction
- No permissions system
- All users can access their own data only (enforced by querying with `user_id`)

**How It Could Be Added**:
1. Add `role` field to `User` model ("admin", "user")
2. Create `AdminMiddleware` that checks `user.role == "admin"`
3. Apply to admin-only routes

### Security Concerns

**Good Practices**:
✅ Passwords hashed with Bcrypt
✅ JWT for stateless auth
✅ Database transactions for financial operations (atomicity)
✅ Input validation (email format, minimum amounts)

**Potential Issues**:
⚠️ **No JWT expiration**: Tokens never expire (could be stolen and used indefinitely)
⚠️ **PIN stored in plaintext**: Transaction PINs not hashed (should use Bcrypt)
⚠️ **No rate limiting**: Brute force attacks possible on login
⚠️ **No HTTPS enforcement**: API uses HTTP (should be HTTPS in production)
⚠️ **Hardcoded base URL**: Frontend has IP address hardcoded (should be configurable)
⚠️ **No 2FA**: Only password for authentication

---

## 8. Environment Configuration

### Backend `.env` File

```bash
# JWT Secret Key (used to sign authentication tokens)
JWT_SECRET=IAMAMANI

# PostgreSQL Database Connection
DB_HOST=localhost          # Database server address
DB_PORT=5432              # PostgreSQL default port
DB_NAME=TUngaDB           # Database name
DB_USERNAME=postgres      # Database user
DB_PASSWORD=password123   # Database password

# QR Code Signing Secret
QR_SECRET=STREAM_QR_SECRET_2026
```

### What Each Variable Does

| Variable | Purpose | What Happens If Missing |
|----------|---------|-------------------------|
| `JWT_SECRET` | Signs and verifies JWT tokens | Falls back to `"SECRET_KEY_DEV"` (insecure for production) |
| `DB_HOST` | PostgreSQL server address | Falls back to `"localhost"` |
| `DB_PORT` | PostgreSQL port | Falls back to `5432` |
| `DB_NAME` | Database name | Falls back to `"TUngaDB"` |
| `DB_USERNAME` | Database user | Falls back to `"postgres"` |
| `DB_PASSWORD` | Database password | Falls back to `"tequiero2024"` (hardcoded default) |
| `QR_SECRET` | Signs QR code payloads | Falls back to `"STREAM_QR_SECRET_2026"` |

### Frontend Configuration

**Hardcoded Values** (should be configurable):
- `baseURL` in `APIService.swift`: `"http://10.12.73.61:8080"`
  - **Issue**: IP address changes between networks
  - **Fix**: Use environment-based configuration or Xcode build configurations

### Example Production `.env`

```bash
# Production Environment Variables

# Strong JWT secret (use random 64-character string)
JWT_SECRET=your-super-secret-jwt-key-min-32-chars-recommended-64

# Production Database (e.g., AWS RDS, Heroku Postgres)
DB_HOST=production-db.amazonaws.com
DB_PORT=5432
DB_NAME=swiftpay_production
DB_USERNAME=swiftpay_user
DB_PASSWORD=super-secure-password-here

# QR Secret (different from dev)
QR_SECRET=production-qr-secret-key-2026
```

---

## 9. Local Setup Guide

### Prerequisites

**Required Software**:
1. **macOS** (for iOS development)
2. **Xcode** 15.0+ (for SwiftUI and iOS Simulator)
3. **Swift** 5.10+ (comes with Xcode)
4. **PostgreSQL** 14+ (database)
5. **Docker** (optional, for easy PostgreSQL setup)

### Step-by-Step Installation

#### Step 1: Clone the Repository

```bash
cd ~/Documents
git clone <repository-url> Tunga
cd Tunga
```

#### Step 2: Set Up PostgreSQL Database

**Option A: Using Docker (Recommended)**

```bash
cd Backend
docker-compose up -d
```

This starts PostgreSQL on `localhost:5432` with:
- Database: `TUngaDB`
- Username: `postgres`
- Password: `tequiero2024`

**Option B: Using Local PostgreSQL**

```bash
# Install PostgreSQL (if not installed)
brew install postgresql@14

# Start PostgreSQL service
brew services start postgresql@14

# Create database
createdb TUngaDB
```

#### Step 3: Configure Backend Environment

```bash
cd Backend

# Create .env file (or edit existing)
cat > .env << EOF
JWT_SECRET=dev-secret-key-change-in-production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=TUngaDB
DB_USERNAME=postgres
DB_PASSWORD=tequiero2024
QR_SECRET=STREAM_QR_SECRET_2026
EOF
```

#### Step 4: Run Backend

```bash
cd Backend

# Install dependencies and build
swift build

# Run the server
swift run

# You should see:
# [ NOTICE ] Server starting on http://0.0.0.0:8080
```

**What Happens on First Run**:
1. Connects to PostgreSQL
2. Runs all migrations (creates tables)
3. Seeds database with Rwandan institutions
4. Starts HTTP server on port 8080

**Verify Backend**:
```bash
curl http://localhost:8080/health
# Should return: {"status":"ok"}
```

#### Step 5: Configure Frontend

1. Open `Stream.xcodeproj` in Xcode
2. Edit `Frontend/Stream/Core/API/APIService.swift`:
   ```swift
   // Change this line:
   private let baseURL = "http://10.12.73.61:8080"
   
   // To:
   private let baseURL = "http://localhost:8080"
   ```

#### Step 6: Run Frontend

1. In Xcode, select a simulator (e.g., iPhone 15 Pro)
2. Press `Cmd + R` to build and run
3. App should launch in simulator

#### Step 7: Create Test Account

1. In simulator, tap "Create Account"
2. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Phone: 0788123456
   - Password: password123
   - PIN: 123456
3. Tap "Sign Up"
4. Go back and login with same credentials

#### Step 8: Link an Institution

1. After login, tap "+" next to "INSTITUTIONS"
2. Select "Bank of Kigali"
3. Enter balance: 500000
4. Tap "Link"
5. Institution appears on dashboard

### Common Setup Errors and Fixes

#### Error: "Connection refused" when starting backend

**Cause**: PostgreSQL not running

**Fix**:
```bash
# Check if PostgreSQL is running
pg_isready

# If not, start it
brew services start postgresql@14
# OR
docker-compose up -d
```

#### Error: "Database does not exist"

**Cause**: Database not created

**Fix**:
```bash
createdb TUngaDB
```

#### Error: "Port 8080 already in use"

**Cause**: Another process using port 8080

**Fix**:
```bash
# Find process using port 8080
lsof -i :8080

# Kill it
kill -9 <PID>

# OR change port in Backend/Sources/App/configure.swift:
app.http.server.configuration.port = 8081
```

#### Error: "Cannot connect to backend" in iOS app

**Cause**: Wrong base URL or backend not running

**Fix**:
1. Verify backend is running: `curl http://localhost:8080/health`
2. Check `baseURL` in `APIService.swift` matches backend address
3. If using physical device, use computer's IP address (not localhost)

#### Error: "Build failed" in Xcode

**Cause**: Swift version mismatch or missing dependencies

**Fix**:
1. Xcode → Preferences → Locations → Command Line Tools (select Xcode version)
2. Clean build folder: `Cmd + Shift + K`
3. Rebuild: `Cmd + B`

---

## 10. How to Modify or Extend the App

### Adding a New Feature: "Scheduled Payments"

Let's walk through adding a feature to schedule future payments.

#### Step 1: Add Database Model (Backend)

**Create**: `Backend/Sources/App/Models/ScheduledPayment.swift`

```swift
import Fluent
import Vapor

final class ScheduledPayment: Model, Content {
    static let schema = "scheduled_payments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "recipient")
    var recipient: String
    
    @Field(key: "amount")
    var amount: Double
    
    @Field(key: "scheduled_date")
    var scheduledDate: Date
    
    @Field(key: "status")
    var status: String // "pending", "completed", "cancelled"
    
    init() { }
    
    init(id: UUID? = nil, userID: UUID, recipient: String, amount: Double, scheduledDate: Date) {
        self.id = id
        self.$user.id = userID
        self.recipient = recipient
        self.amount = amount
        self.scheduledDate = scheduledDate
        self.status = "pending"
    }
}
```

#### Step 2: Create Migration

**Create**: `Backend/Sources/App/Migrations/CreateScheduledPayment.swift`

```swift
import Fluent

struct CreateScheduledPayment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("scheduled_payments")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("recipient", .string, .required)
            .field("amount", .double, .required)
            .field("scheduled_date", .datetime, .required)
            .field("status", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("scheduled_payments").delete()
    }
}
```

**Register Migration** in `configure.swift`:
```swift
app.migrations.add(CreateScheduledPayment())
```

#### Step 3: Create Controller

**Create**: `Backend/Sources/App/Controllers/ScheduledPaymentController.swift`

```swift
import Fluent
import Vapor

struct ScheduledPaymentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scheduled = routes.grouped("scheduled-payments")
            .grouped(SessionValidationMiddleware())
        
        scheduled.get(use: index)
        scheduled.post(use: create)
        scheduled.delete(":id", use: cancel)
    }
    
    @Sendable
    func index(req: Request) async throws -> StreamResponse<[ScheduledPayment]> {
        let user = try req.auth.require(User.self)
        let payments = try await ScheduledPayment.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .all()
        return StreamResponse(success: true, data: payments)
    }
    
    struct CreateRequest: Content {
        let recipient: String
        let amount: Double
        let scheduledDate: Date
    }
    
    @Sendable
    func create(req: Request) async throws -> StreamResponse<ScheduledPayment> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(CreateRequest.self)
        
        let payment = ScheduledPayment(
            userID: try user.requireID(),
            recipient: input.recipient,
            amount: input.amount,
            scheduledDate: input.scheduledDate
        )
        try await payment.save(on: req.db)
        
        return StreamResponse(success: true, message: "Payment scheduled", data: payment)
    }
    
    @Sendable
    func cancel(req: Request) async throws -> StreamResponse<ScheduledPayment> {
        let user = try req.auth.require(User.self)
        let id = try req.parameters.require("id", as: UUID.self)
        
        guard let payment = try await ScheduledPayment.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard try payment.$user.id == user.requireID() else {
            throw Abort(.forbidden)
        }
        
        payment.status = "cancelled"
        try await payment.save(on: req.db)
        
        return StreamResponse(success: true, data: payment)
    }
}
```

**Register Controller** in `routes.swift`:
```swift
try app.register(collection: ScheduledPaymentController())
```

#### Step 4: Add Frontend Model

**Edit**: `Frontend/Stream/Core/Models/Models.swift`

```swift
struct ScheduledPayment: Identifiable, Decodable {
    let id: UUID
    let recipient: String
    let amount: Double
    let scheduledDate: Date
    let status: String
}
```

#### Step 5: Add API Methods

**Edit**: `Frontend/Stream/Core/API/APIService.swift`

```swift
// Add to APIService class
func fetchScheduledPayments() async throws -> StreamResponse<[ScheduledPayment]> {
    return try await request("/scheduled-payments")
}

func createScheduledPayment(recipient: String, amount: Double, date: Date) async throws -> StreamResponse<ScheduledPayment> {
    struct CreateDTO: Encodable {
        let recipient: String
        let amount: Double
        let scheduledDate: Date
    }
    let dto = CreateDTO(recipient: recipient, amount: amount, scheduledDate: date)
    return try await request("/scheduled-payments", method: "POST", body: dto)
}

func cancelScheduledPayment(id: UUID) async throws -> StreamResponse<ScheduledPayment> {
    return try await request("/scheduled-payments/\(id.uuidString)", method: "DELETE")
}
```

#### Step 6: Create UI View

**Create**: `Frontend/Stream/Flows/Main/ScheduledPaymentsView.swift`

```swift
import SwiftUI

struct ScheduledPaymentsView: View {
    @State private var payments: [ScheduledPayment] = []
    @State private var isLoading = false
    
    var body: some View {
        List(payments) { payment in
            VStack(alignment: .leading) {
                Text(payment.recipient)
                    .font(.headline)
                Text("\(Int(payment.amount)) RWF")
                    .font(.subheadline)
                Text(payment.scheduledDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Scheduled Payments")
        .onAppear {
            Task {
                isLoading = true
                if let response = try? await APIService.shared.fetchScheduledPayments() {
                    payments = response.data ?? []
                }
                isLoading = false
            }
        }
    }
}
```

#### Step 7: Add to Navigation

**Edit**: `Frontend/Stream/Flows/Main/SettingsView.swift`

```swift
// Add in settings list
NavigationLink(destination: ScheduledPaymentsView()) {
    SettingRowContent(icon: "calendar", title: "SCHEDULED PAYMENTS")
}
```

### Where to Write Backend Logic

**Controllers** (`Backend/Sources/App/Controllers/`):
- HTTP request handling
- Input validation
- Response formatting
- **Keep thin**: Delegate business logic to services

**Services** (`Backend/Sources/App/Services/`):
- Business logic
- Complex calculations
- Multi-step operations
- Database transactions

**Models** (`Backend/Sources/App/Models/`):
- Data structure
- Database schema
- Simple computed properties

### Where to Write Frontend Logic

**Views** (`Frontend/Stream/Flows/`):
- UI layout
- User interactions
- **Keep thin**: Delegate logic to ViewModels

**ViewModels** (`Frontend/Stream/Flows/Actions/`):
- State management
- API calls
- Business logic
- Data transformation

**APIService** (`Frontend/Stream/Core/API/`):
- HTTP communication only
- No business logic

### How to Safely Change Existing Code

**Before Changing**:
1. ✅ Understand what the code does (read it thoroughly)
2. ✅ Check where it's used (Xcode: Right-click → Find Call Hierarchy)
3. ✅ Test current behavior (run app, try feature)

**Making Changes**:
1. ✅ Make small, incremental changes
2. ✅ Test after each change
3. ✅ Use version control (git commit frequently)

**Database Changes**:
- ⚠️ **Never edit old migrations** (they've already run)
- ✅ Create new migration for schema changes
- ✅ Test migration on fresh database

**API Changes**:
- ⚠️ **Breaking changes** (changing field names, removing fields) break frontend
- ✅ Add new fields (backward compatible)
- ✅ Version API if breaking changes needed (`/v2/transactions`)

---

## 11. Known Issues / Code Smells

### 🔴 Critical Issues

#### 1. **No JWT Expiration**
**Location**: `Backend/Sources/App/Models/User.swift` (UserPayload)

**Problem**: JWT tokens never expire. If stolen, they work forever.

**Why It's Bad**: Security risk. Stolen token = permanent access.

**Fix**:
```swift
struct UserPayload: JWTPayload {
    var sub: SubjectClaim
    var name: String
    var email: String
    var tokenVersion: Int
    var exp: ExpirationClaim  // ADD THIS
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()  // ADD THIS
    }
}

// When creating token:
let payload = UserPayload(
    sub: .init(value: user.id!.uuidString),
    name: user.name,
    email: user.email,
    tokenVersion: user.tokenVersion,
    exp: .init(value: Date().addingTimeInterval(86400))  // 24 hours
)
```

#### 2. **PIN Stored in Plaintext**
**Location**: `Backend/Sources/App/Models/User.swift`

**Problem**: Transaction PINs stored as plain text in database.

**Why It's Bad**: Database breach = all PINs exposed.

**Fix**: Hash PINs with Bcrypt like passwords.

#### 3. **Hardcoded Base URL**
**Location**: `Frontend/Stream/Core/API/APIService.swift`

**Problem**: `baseURL = "http://10.12.73.61:8080"` only works on specific network.

**Why It's Bad**: App breaks when IP changes or on different network.

**Fix**: Use Xcode build configurations or environment-based config.

### 🟡 Medium Issues

#### 4. **No Rate Limiting**
**Location**: All controllers

**Problem**: No protection against brute force attacks.

**Why It's Bad**: Attacker can try unlimited login attempts.

**Fix**: Add rate limiting middleware (e.g., 5 attempts per minute per IP).

#### 5. **Inconsistent Error Handling**
**Location**: Frontend views

**Problem**: Some views show errors, some silently fail.

**Example**: `DashboardView` catches errors but doesn't show user.

**Fix**: Centralized error handling with user-friendly messages.

#### 6. **No Database Indexing**
**Location**: Migrations

**Problem**: No indexes on frequently queried fields (e.g., `user_id`, `email`).

**Why It's Bad**: Slow queries as data grows.

**Fix**: Add indexes in migrations:
```swift
.field("email", .string, .required)
.unique(on: "email")  // Adds index
```

### 🟢 Minor Issues / Code Smells

#### 7. **Magic Numbers**
**Location**: `TransactionService.swift`

**Problem**: Hardcoded values like `10` (minimum amount), `2000000` (daily limit).

**Fix**: Define as constants:
```swift
struct TransactionLimits {
    static let minimumAmount: Double = 10
    static let defaultDailyLimit: Double = 2_000_000
    static let defaultMonthlyLimit: Double = 10_000_000
}
```

#### 8. **Duplicate Code**
**Location**: `SendMoneyFlow`, `TopUpFlow`, `RequestMoneyFlow`

**Problem**: Similar step-by-step wizards with duplicated logic.

**Fix**: Create reusable `TransactionWizard` component.

#### 9. **Unclear Naming**
**Location**: `LinkedAccount` model

**Problem**: "LinkedAccount" is vague. What's it linked to?

**Better Name**: `UserInstitutionAccount` or `AccountLink`

#### 10. **Missing Documentation**
**Location**: Everywhere

**Problem**: No code comments explaining complex logic.

**Fix**: Add comments to:
- Complex algorithms (e.g., QR signature generation)
- Business rules (e.g., why daily limit is checked)
- Non-obvious code

#### 11. **No Logging**
**Location**: Backend services

**Problem**: Hard to debug production issues without logs.

**Fix**: Add structured logging:
```swift
req.logger.info("Transaction created", metadata: [
    "user_id": .string(user.id!.uuidString),
    "amount": .string("\(amount)"),
    "type": .string("SEND")
])
```

#### 12. **Inconsistent Date Handling**
**Location**: QR code decoding

**Problem**: Frontend tries 4 different date decoding strategies.

**Why It's Messy**: Backend and frontend should agree on one format (ISO8601).

**Fix**: Standardize on ISO8601 everywhere, remove fallbacks.

---

## 12. Mental Model Summary

### The Big Picture

**SwiftPay Plus is a financial aggregator app that lets Rwandan users manage multiple bank and mobile money accounts in one place.**

Think of it like this:

```
You have money in 3 places:
  - Bank of Kigali: 500,000 RWF
  - MTN Mobile Money: 50,000 RWF
  - I&M Bank: 200,000 RWF

Instead of 3 apps, you use SwiftPay Plus:
  ✅ See total: 750,000 RWF
  ✅ Move money between them
  ✅ Send money from any account
  ✅ Track all transactions in one place
```

### Core Concepts

1. **Institution**: A bank or mobile money provider (e.g., Bank of Kigali)
2. **LinkedAccount**: Your account at a specific institution (balance, limits, frozen status)
3. **Transaction**: Money movement (send, receive, top-up)
4. **QR Code**: Signed payment request/offer

### Data Flow in One Sentence

**User interacts with SwiftUI views → APIService makes HTTP calls → Vapor routes to controllers → Controllers call services → Services update database → Response flows back to update UI.**

### If You Remember Only One Thing

**This app is a thin layer on top of a PostgreSQL database. The backend enforces business rules (limits, balances, freezing), and the frontend is just a pretty interface to trigger those rules.**

The real "app" is the database schema + transaction service logic. Everything else is plumbing.

---

## Appendix: Quick Reference

### Key Files Cheat Sheet

| File | Purpose | When to Edit |
|------|---------|--------------|
| `configure.swift` | App setup | Adding middleware, changing DB config |
| `routes.swift` | API endpoints | Adding new routes |
| `TransactionService.swift` | Transaction logic | Changing business rules |
| `APIService.swift` | HTTP client | Adding new API calls |
| `AppState.swift` | Global state | Adding app-wide state |
| `MainContainerView.swift` | Tab bar | Adding/removing tabs |

### Common Commands

```bash
# Backend
swift build                    # Build backend
swift run                      # Run backend
swift package clean            # Clean build

# Database
psql TUngaDB                   # Connect to database
\dt                            # List tables
\d users                       # Describe users table

# Frontend (in Xcode)
Cmd + R                        # Run app
Cmd + B                        # Build
Cmd + Shift + K                # Clean build
Cmd + .                        # Stop running app
```

### API Endpoints Quick Reference

```
POST   /auth/signup
POST   /auth/login
GET    /user/profile
PUT    /user/profile
POST   /user/pin
POST   /user/terminate-sessions

GET    /institutions
GET    /institutions/available
POST   /institutions/link
GET    /institutions/:id
GET    /institutions/:id/transactions
POST   /institutions/:id/freeze
POST   /institutions/:id/limits

GET    /transactions
POST   /transactions/send
POST   /transactions/topup
POST   /transactions/request
POST   /transactions/qr/generate
POST   /transactions/qr/execute

GET    /news
GET    /notifications
POST   /notifications/:id/read
```

---

**End of Documentation**

This README should give you everything you need to understand, run, and modify SwiftPay Plus. If you're still confused about something, trace through the code with a debugger - seeing data flow in real-time is the best teacher.

Good luck! 🚀
