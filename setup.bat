@echo off
REM Windows batch script setup deployment

echo.
echo 🚀 FEPA Deployment Setup
echo ========================
echo.

REM Check Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
  echo ❌ Docker không được cài đặt
  exit /b 1
)

for /f "tokens=*" %%i in ('docker --version') do set DOCKER_VERSION=%%i
echo ✅ %DOCKER_VERSION%

REM Check Docker Compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
  echo ❌ Docker Compose không được cài đặt
  exit /b 1
)

for /f "tokens=*" %%i in ('docker-compose --version') do set COMPOSE_VERSION=%%i
echo ✅ %COMPOSE_VERSION%

REM Copy .env if not exists
if not exist ".env" (
  echo.
  echo 📝 Tạo .env từ .env.example...
  copy .env.example .env
  echo ✅ Tạo .env thành công
  echo ⚠️  Hãy chỉnh sửa .env nếu cần
) else (
  echo ✅ .env đã tồn tại
)

echo.
echo 📦 Xây dựng Docker images...
docker-compose build

echo.
echo ✅ Setup hoàn tất!
echo.
echo Để chạy services:
echo   docker-compose up -d
echo.
echo Để kiểm tra logs:
echo   docker-compose logs -f api-gateway
echo.
echo Để dừng services:
echo   docker-compose down
