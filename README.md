# FEPA Docker Deployment

Thư mục chứa Docker configuration cho deployment.

## Chạy All Services

```bash
docker-compose up -d
```

## Logs

```bash
docker-compose logs -f api-gateway
docker-compose logs -f auth-service
```

## Dừng Services

```bash
docker-compose down
```

## Cấu Hình

Copy `.env.example` thành `.env` nếu cần custom configuration.

## Services

- **API Gateway**: http://localhost:3000

  - Docs: http://localhost:3000/docs
  - Health: http://localhost:3000/api/v1/health

- **Auth Service**: TCP port 3001
- **Expense Service**: TCP port 3002
- **Budget Service**: TCP port 3003

## Xây Dựng Lại Images

```bash
docker-compose build --no-cache
```

## Production Build

Chỉnh `.env` với `NODE_ENV=production` trước khi build.
