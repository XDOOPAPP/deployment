#!/bin/bash
# Script setup deployment

set -e

echo "🚀 FEPA Deployment Setup"
echo "========================"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
  echo "❌ Docker không được cài đặt"
  exit 1
fi

echo "✅ Docker: $(docker --version)"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo "❌ Docker Compose không được cài đặt"
  exit 1
fi

echo "✅ Docker Compose: $(docker-compose --version)"

# Copy .env if not exists
if [ ! -f ".env" ]; then
  echo ""
  echo "📝 Tạo .env từ .env.example..."
  cp .env.example .env
  echo "✅ Tạo .env thành công"
  echo "⚠️  Hãy chỉnh sửa .env nếu cần"
else
  echo "✅ .env đã tồn tại"
fi

echo ""
echo "📦 Xây dựng Docker images..."
docker-compose build

echo ""
echo "✅ Setup hoàn tất!"
echo ""
echo "Để chạy services:"
echo "  docker-compose up -d"
echo ""
echo "Để kiểm tra logs:"
echo "  docker-compose logs -f api-gateway"
echo ""
echo "Để dừng services:"
echo "  docker-compose down"
