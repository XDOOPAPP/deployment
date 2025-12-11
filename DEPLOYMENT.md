# FEPA Deployment Documentation

## 📁 Cấu Trúc Thư Mục Deployment

```
deployment/
├── docker-compose.yml          # Docker Compose config
├── .dockerignore               # Exclude files khi build Docker images
├── .env.example                # Template biến môi trường (development)
├── .env.production.example     # Template biến môi trường (production)
├── README.md                   # Hướng dẫn cơ bản
├── DEPLOYMENT.md               # File này - Chi tiết deployment
├── setup.sh                    # Script setup (Linux/Mac)
├── setup.bat                   # Script setup (Windows)
├── health-check.sh             # Script kiểm tra health (Linux/Mac)
└── health-check.bat            # Script kiểm tra health (Windows)
```

## 🚀 Quick Start

### 1. Setup (lần đầu)

**Linux/Mac:**

```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**

```cmd
setup.bat
```

### 2. Chạy Services

```bash
docker-compose up -d
```

### 3. Kiểm tra Health

**Linux/Mac:**

```bash
chmod +x health-check.sh
./health-check.sh
```

**Windows:**

```cmd
health-check.bat
```

### 4. Dừng Services

```bash
docker-compose down
```

## 📋 Các Lệnh Docker Compose

```bash
# Xem logs
docker-compose logs -f                 # Tất cả services
docker-compose logs -f api-gateway     # Chỉ API Gateway

# Rebuild images
docker-compose build --no-cache

# Xem running containers
docker-compose ps

# Dừng từng service
docker-compose stop auth-service

# Restart
docker-compose restart api-gateway

# Remove all (data sẽ bị xóa)
docker-compose down -v
```

## 🔧 Cấu Hình Environment

### Development (.env)

```
NODE_ENV=development
LOG_LEVEL=debug
JWT_SECRET=dev-secret-key-change-in-production
```

### Production (.env.production)

1. Copy `.env.production.example` → `.env.production`
2. Thay đổi giá trị sensitive:

   - `JWT_SECRET` - Dùng key dài, bảo mật
   - Database URL nếu cần
   - Log level = `info` hoặc `warn`

3. Sử dụng khi run:

```bash
docker-compose --env-file .env.production up -d
```

## 🐳 Dockerfile Best Practices

Mỗi service có `Dockerfile` riêng (ở service folder):

```dockerfile
# Multi-stage build (giảm image size)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3001
CMD ["node", "dist/main"]
```

## 🔍 Health Checks

### API Gateway

```bash
curl http://localhost:3000/api/v1/health
```

Response:

```json
{
  "status": "ok",
  "service": "api-gateway",
  "timestamp": "2025-12-11T10:00:00Z",
  "environment": "development"
}
```

## 📊 Monitoring

### Docker Stats

```bash
docker stats
```

### Container Logs

```bash
docker-compose logs api-gateway --tail 100
```

## 🚨 Troubleshooting

### Port đã sử dụng

```bash
# Kiểm tra port
lsof -i :3000  # Linux/Mac
netstat -ano | findstr :3000  # Windows

# Thay đổi port trong docker-compose.yml
ports:
  - "3001:3000"  # External:Internal
```

### Container không start

```bash
# Xem lỗi
docker-compose logs api-gateway

# Rebuild
docker-compose build --no-cache api-gateway
docker-compose up api-gateway
```

### Network issues

```bash
# Kiểm tra network
docker network ls
docker network inspect fepa-network

# Restart docker
docker-compose down
docker-compose up -d
```

## 🔐 Security Notes

1. **Environment Variables**

   - Không commit `.env` vào git
   - Dùng `.env.example` làm template
   - Thay đổi `JWT_SECRET` cho production

2. **Docker Images**

   - Sử dụng `node:20-alpine` (nhỏ hơn)
   - Không chạy container as root

3. **Network**

   - Services communicate qua internal network
   - Chỉ expose gateway port (3000)

4. **Volumes** (future)
   - Database data persistence
   - Logs persistence

## 📈 Scaling

Để chạy nhiều replicas của 1 service:

```yaml
# docker-compose.yml
services:
  expense-service:
    deploy:
      replicas: 3 # Chạy 3 instances
```

Rồi sử dụng load balancer ở gateway.

## 🔄 CI/CD Integration

Ví dụ GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: |
          cd deployment
          docker-compose build
          docker-compose up -d
```

## 📝 Checklists

### Pre-Deployment

- [ ] `.env` đã tạo và config đúng
- [ ] Tất cả services có `Dockerfile`
- [ ] Build test thành công
- [ ] Health checks pass
- [ ] Logs không có error

### Post-Deployment

- [ ] Tất cả containers đang chạy
- [ ] Health checks pass
- [ ] API Gateway nhận được requests
- [ ] Logs bình thường
- [ ] Database connected (nếu có)

## 📚 References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NestJS Deployment](https://docs.nestjs.com/deployment)
