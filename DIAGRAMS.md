# FEPA - System Diagrams

Tài liệu tập trung vào các sơ đồ kiến trúc, quan hệ và luồng chính của hệ thống FEPA.

## 1. System Architecture (Microservices)

```mermaid
graph TB
    Client[Client (Web/Mobile)]
    Gateway[API Gateway :3000]

    Auth[Auth Service :3001]
    Expense[Expense Service :3002]
    Budget[Budget Service :3003]
    Blog[Blog Service :3004]
    Sub[Subscription Service :3005]
    Notif[Notification Service :3006]
    OCR[OCR Service :3007]
    AI[AI Service :3008]

    DB_Auth[(Auth DB)]
    DB_Expense[(Expense DB)]
    DB_Budget[(Budget DB)]
    DB_Blog[(Blog DB)]
    DB_Sub[(Subscription DB)]
    DB_Notif[(Notification DB)]
    DB_OCR[(OCR DB)]
    DB_AI[(AI DB)]

    Client -->|HTTP/REST| Gateway
    Gateway -->|TCP| Auth
    Gateway -->|TCP| Expense
    Gateway -->|TCP| Budget
    Gateway -->|TCP| Blog
    Gateway -->|TCP| Sub
    Gateway -->|TCP| Notif
    Gateway -->|TCP| OCR
    Gateway -->|TCP| AI

    Auth --> DB_Auth
    Expense --> DB_Expense
    Budget --> DB_Budget
    Blog --> DB_Blog
    Sub --> DB_Sub
    Notif --> DB_Notif
    OCR --> DB_OCR
    AI --> DB_AI

    Budget -.->|alerts| Notif
    OCR -.->|job done| Notif
    AI -.->|insights| Notif
    Budget -.->|spend data| Expense
    AI -.->|data| Expense
    AI -.->|data| Budget
```

## 2. High-Level Class Diagram (Gateway + Services)

```mermaid
classDiagram
    class ApiGateway {
      +AuthController
      +ExpensesController
      +BudgetsController
      +BlogsController
      +(others: Subscription, Notification, OCR, AI)
    }

    class AuthController {
      +register()
      +verifyOtp()
      +login()
      +refresh()
      +getProfile()
      +forgotPassword()
      +resetPassword()
    }

    class ExpensesController {
      +create()
      +findAll()
      +findOne()
      +update()
      +remove()
      +summary()
    }

    class BudgetsController {
      +create()
      +findAll()
      +findOne()
      +update()
      +remove()
      +progress()
    }

    class BlogController {
      +findAll()
      +findBySlug()
      +create()
      +update()
      +delete()
    }

    class AuthService_MS {
      +register()
      +verifyOtp()
      +login()
      +refresh()
      +verifyToken()
      +forgotPassword()
      +resetPassword()
    }

    class ExpenseService_MS {
      +create()
      +findAll()
      +findOne()
      +update()
      +remove()
      +summary()
    }

    class BudgetService_MS {
      +create()
      +findAll()
      +findOne()
      +update()
      +remove()
      +progress()
    }

    class BlogService_MS {
      +create()
      +findAll()
      +findOne()
      +findBySlug()
      +update()
      +remove()
    }

    class SubscriptionService_MS {
      +plans()
      +current()
      +subscribe()
      +cancel()
      +history()
    }

    class NotificationService_MS {
      +create()
      +findAll()
      +markRead()
      +markAllRead()
    }

    class OcrService_MS {
      +scan()
      +history()
      +findOne()
    }

    class AiService_MS {
      +insights()
      +predictions()
      +categorize()
    }

    ApiGateway --> AuthService_MS : TCP
    ApiGateway --> ExpenseService_MS : TCP
    ApiGateway --> BudgetService_MS : TCP
    ApiGateway --> BlogService_MS : TCP
    ApiGateway --> SubscriptionService_MS : TCP
    ApiGateway --> NotificationService_MS : TCP
    ApiGateway --> OcrService_MS : TCP
    ApiGateway --> AiService_MS : TCP

    BudgetService_MS --> ExpenseService_MS : expense.summary
    AiService_MS --> ExpenseService_MS : expense.findAll
    AiService_MS --> BudgetService_MS : budget.findAll
    NotificationService_MS <.. BudgetService_MS : notif.create
    NotificationService_MS <.. OcrService_MS : notif.create
```

## 3. Key Sequence Diagrams

### 3.1. User Registration + OTP Verification

```mermaid
sequenceDiagram
    actor Guest
    participant Gateway as API Gateway
    participant Auth as Auth Service
    participant Email as Email Service
    participant DB as Auth DB

    Guest->>Gateway: POST /auth/register {email, pw, fullName}
    Gateway->>Auth: auth.register
    Auth->>DB: check email
    Auth->>Auth: hash pw, generate+hash OTP
    Auth->>DB: create user {isVerified=false, otpHash, otpExpiredAt}
    Auth->>Email: send OTP
    Auth-->>Gateway: {message: "OTP sent"}
    Gateway-->>Guest: 200 OK

    Guest->>Gateway: POST /auth/verify-otp {email, otp}
    Gateway->>Auth: auth.verifyOtp
    Auth->>DB: get user+otp
    Auth->>Auth: verify OTP & expiry
    Auth->>DB: update isVerified=true; create RefreshToken
    Auth-->>Gateway: {accessToken, refreshToken}
    Gateway-->>Guest: 200 OK
```

### 3.2. Create Expense + Summary

```mermaid
sequenceDiagram
    actor User
    participant Gateway as API Gateway
    participant Expense as Expense Service
    participant DB as Expense DB

    User->>Gateway: POST /expenses {desc, amount, category, spentAt}
    Gateway->>Expense: expense.create {userId, ...}
    Expense->>Expense: validate category
    Expense->>DB: INSERT Expense
    DB-->>Expense: created
    Expense-->>Gateway: expense
    Gateway-->>User: 201 Created

    User->>Gateway: GET /expenses/summary?from=..&to=..
    Gateway->>Expense: expense.summary {userId, from, to}
    Expense->>DB: aggregate sum, group by category/time
    DB-->>Expense: totals
    Expense-->>Gateway: summary
    Gateway-->>User: 200 OK
```

### 3.3. Budget Progress (cross-service)

```mermaid
sequenceDiagram
    actor User
    participant Gateway as API Gateway
    participant Budget as Budget Service
    participant Expense as Expense Service
    participant BDB as Budget DB

    User->>Gateway: GET /budgets/{id}/progress
    Gateway->>Budget: budget.progress {id, userId}
    Budget->>BDB: SELECT budget
    Budget->>Expense: expense.summary {userId, category, from, to}
    Expense-->>Budget: {totalAmount}
    Budget->>Budget: calc percentage, remaining
    Budget-->>Gateway: {progress}
    Gateway-->>User: 200 OK
```

### 3.4. OCR Scan (async)

```mermaid
sequenceDiagram
    actor User
    participant Gateway as API Gateway
    participant Storage as File Storage
    participant OCR as OCR Service
    participant Queue as Job Queue
    participant DB as OCR DB

    User->>Gateway: POST /ocr/scan {file}
    Gateway->>Storage: upload file
    Storage-->>Gateway: fileUrl
    Gateway->>OCR: ocr.scan {userId, fileUrl}
    OCR->>DB: INSERT OcrJob {status=queued}
    OCR->>Queue: enqueue jobId
    OCR-->>Gateway: {jobId, status=queued}
    Gateway-->>User: 202 Accepted

    Queue->>OCR: process jobId
    OCR->>Storage: download file
    OCR->>OCR: run OCR
    OCR->>DB: UPDATE job {status=completed, resultJson}
```

## 4. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    %% Auth
    USER ||--o{ REFRESH_TOKEN : has
    USER {
      uuid id
      string email
      string passwordHash
      string role
      string fullName
      timestamptz createdAt
      timestamptz updatedAt
    }
    REFRESH_TOKEN {
      uuid id
      uuid userId
      string tokenHash
      timestamptz expiresAt
      timestamptz createdAt
    }

    %% Expense
    EXPENSE ||..|| USER : owned_by
    CATEGORY ||--o{ EXPENSE : categorizes
    EXPENSE {
      uuid id
      uuid userId
      decimal amount
      string description
      string category
      date spentAt
      timestamptz createdAt
      timestamptz updatedAt
    }
    CATEGORY {
      string slug
      string name
    }

    %% Budget
    BUDGET ||..|| USER : owned_by
    BUDGET {
      uuid id
      uuid userId
      string name
      string category
      decimal limitAmount
      date startDate
      date endDate
      timestamptz createdAt
      timestamptz updatedAt
    }

    %% Blog
    BLOG {
      uuid id
      string title
      string slug
      string content
      string status
      string author
      timestamptz publishedAt
      timestamptz createdAt
      timestamptz updatedAt
    }

    %% Subscription
    PLAN ||--o{ SUBSCRIPTION : referenced_by
    USER ||--o{ SUBSCRIPTION : subscribes
    PLAN {
      uuid id
      string name
      decimal price
      string interval
      timestamptz createdAt
    }
    SUBSCRIPTION {
      uuid id
      uuid userId
      uuid planId
      string status
      date startDate
      date endDate
      timestamptz createdAt
    }

    %% Notification
    USER ||--o{ NOTIFICATION : receives
    NOTIFICATION {
      uuid id
      uuid userId
      string title
      string body
      string type
      boolean isRead
      timestamptz createdAt
    }

    %% OCR
    USER ||--o{ OCR_JOB : owns
    OCR_JOB {
      uuid id
      uuid userId
      string status
      string fileUrl
      json resultJson
      timestamptz createdAt
      timestamptz completedAt
    }

    %% AI
    USER ||--o{ AI_INSIGHT : requested_by
    AI_INSIGHT {
      uuid id
      uuid userId
      string inputType
      json requestPayload
      json responsePayload
      timestamptz createdAt
    }
```

## 5. Ghi chú

- Kiến trúc theo mô hình microservices, giao tiếp TCP qua NestJS `ClientProxy`.
- Mỗi service sở hữu database riêng (PostgreSQL cho Prisma services, MongoDB cho `auth-service` legacy).
- Flow cross-service chính: `budget.progress` gọi `expense.summary`; AI tổng hợp dữ liệu từ Expense/Budget; Notification nhận trigger từ Budget/OCR/AI.

**Last updated**: December 19, 2025
