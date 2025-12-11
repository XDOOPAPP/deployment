@echo off
REM Windows batch script để kiểm tra health của tất cả services

echo.
echo 🔍 Checking FEPA Services Health...
echo.

setlocal enabledelayedexpansion

set "GATEWAY_URL=http://localhost:3000/api/v1/health"
set "AUTH_URL=http://localhost:4001/health"
set "EXPENSE_URL=http://localhost:4002/health"
set "BUDGET_URL=http://localhost:4003/health"

echo Checking API Gateway...
curl -s %GATEWAY_URL% >nul 2>&1
if !errorlevel! equ 0 (
  echo ✅ API Gateway: OK
) else (
  echo ❌ API Gateway: FAILED
)

echo Checking Auth Service...
curl -s %AUTH_URL% >nul 2>&1
if !errorlevel! equ 0 (
  echo ✅ Auth Service: OK
) else (
  echo ❌ Auth Service: FAILED
)

echo Checking Expense Service...
curl -s %EXPENSE_URL% >nul 2>&1
if !errorlevel! equ 0 (
  echo ✅ Expense Service: OK
) else (
  echo ❌ Expense Service: FAILED
)

echo Checking Budget Service...
curl -s %BUDGET_URL% >nul 2>&1
if !errorlevel! equ 0 (
  echo ✅ Budget Service: OK
) else (
  echo ❌ Budget Service: FAILED
)

echo.
echo 📊 Running Services:
docker-compose ps
