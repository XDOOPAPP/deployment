#!/bin/bash
# Script để kiểm tra health của tất cả services

echo "🔍 Checking FEPA Services Health..."

GATEWAY_URL="http://localhost:3000/api/v1/health"
AUTH_URL="http://localhost:4001/health"
EXPENSE_URL="http://localhost:4002/health"
BUDGET_URL="http://localhost:4003/health"

SERVICES=(
  "API Gateway:$GATEWAY_URL"
  "Auth Service:$AUTH_URL"
  "Expense Service:$EXPENSE_URL"
  "Budget Service:$BUDGET_URL"
)

for service in "${SERVICES[@]}"; do
  IFS=':' read -r name url <<< "$service"
  
  response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  
  if [ "$response" = "200" ]; then
    echo "✅ $name: OK"
  else
    echo "❌ $name: FAILED (HTTP $response)"
  fi
done

echo ""
echo "📊 Running Services:"
docker-compose ps
