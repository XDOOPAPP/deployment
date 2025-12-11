a

## FEPA - API Routes (Gateway -> Services)

Routes bám sát schema trong [deployment/DATABASE.md](deployment/DATABASE.md). Gateway nhận HTTP, chuyển TCP message pattern `{ cmd: 'domain.action' }` đến từng service.

### Auth Service (auth-service)

- POST `/api/v1/auth/register` → `auth.register` (public) — tạo User, trả access/refresh token
- POST `/api/v1/auth/login` → `auth.login` (public)
- POST `/api/v1/auth/refresh` → `auth.refresh` (public)
- GET `/api/v1/auth/me` → `auth.profile` (auth)
- POST `/api/v1/auth/verify` → `auth.verify_token` (internal)

### Expense Service (expense-service)

- GET `/api/v1/expenses` → `expense.find_all` (auth; filter: from, to, category, pagination)
- POST `/api/v1/expenses` → `expense.create` (auth)
- GET `/api/v1/expenses/:id` → `expense.find_one` (auth)
- PUT `/api/v1/expenses/:id` → `expense.update` (auth)
- DELETE `/api/v1/expenses/:id` → `expense.delete` (auth)
- GET `/api/v1/expenses/summary` → `expense.summary` (auth; tổng hợp thời gian/category)
- GET `/api/v1/expenses/categories` → `expense.categories` (public; dựa bảng Category)

### Budget Service (budget-service)

- GET `/api/v1/budgets` → `budget.find_all` (auth)
- POST `/api/v1/budgets` → `budget.create` (auth)
- GET `/api/v1/budgets/:id` → `budget.find_one` (auth)
- PUT `/api/v1/budgets/:id` → `budget.update` (auth)
- DELETE `/api/v1/budgets/:id` → `budget.delete` (auth)
- GET `/api/v1/budgets/:id/progress` → `budget.progress` (auth; tính dựa expenses + budget)

### Blog Service (blog-service)

- GET `/api/v1/blogs` → `blog.find_all` (public; filter status/pagination)
- GET `/api/v1/blogs/:slug` → `blog.find_by_slug` (public)
- POST `/api/v1/blogs` → `blog.create` (admin)
- PUT `/api/v1/blogs/:id` → `blog.update` (admin)
- DELETE `/api/v1/blogs/:id` → `blog.delete` (admin)

### Subscription Service (subscription-service)

- GET `/api/v1/subscriptions/plans` → `sub.plans` (public)
- GET `/api/v1/subscriptions/current` → `sub.current` (auth)
- POST `/api/v1/subscriptions` → `sub.subscribe` (auth; body: planId)
- POST `/api/v1/subscriptions/cancel` → `sub.cancel` (auth)
- GET `/api/v1/subscriptions/history` → `sub.invoices` (auth; dùng bảng Subscription làm lịch sử)

### Notification Service (notification-service)

- GET `/api/v1/notifications` → `notif.find_all` (auth; query: unreadOnly?)
- POST `/api/v1/notifications/:id/read` → `notif.mark_read` (auth)
- POST `/api/v1/notifications/read-all` → `notif.mark_all_read` (auth)

### OCR Service (ocr-service)

- POST `/api/v1/ocr/scan` → `ocr.scan` (auth; tạo OcrJob status=queued)
- GET `/api/v1/ocr/jobs` → `ocr.history` (auth)
- GET `/api/v1/ocr/jobs/:jobId` → `ocr.find_one` (auth)

### AI Service (ai-service)

- GET `/api/v1/ai/insights` → `ai.insights` (auth; filter: period/inputType)
- POST `/api/v1/ai/insights` → `ai.insights` (auth; lưu insight mới, dùng requestPayload/responsePayload)
- GET `/api/v1/ai/predictions` → `ai.predictions` (auth)
- POST `/api/v1/ai/categorize` → `ai.categorize` (auth; trả category, có thể log vào AiInsight)
