#!/usr/bin/env bash
echo "🔧 Initializing development environment..."

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo "❌ $1 is not installed. Please install it."
    exit 1
  fi
  echo "🆗 $1 version: $($1 --version || true)"
}

echo "⛏️ Verifying required tools..."
check_tool git
check_tool java
check_tool node
check_tool lefthook
check_tool docker
echo "✅ All required tools are available."

echo ""
echo "🔮 Installing Git to use rebase on pull.."
git config --local pull.rebase true
echo "✅ Configured Git to use rebase on pull"

echo ""
echo "🪝 Installing Git hooks with Lefthook..."
lefthook install
echo "✅ Git hooks installed successfully."

echo ""
echo "📦 Installing frontend dependencies..."
(cd "$SCRIPT_DIR"/../frontend/mobile && npm install)
(cd "$SCRIPT_DIR"/../frontend/web && npm install)
echo "✅ Frontend dependencies installed successfully."

echo ""
echo "⚙️ Installing backend dependencies..."
(cd "$SCRIPT_DIR"/../backend && ./gradlew clean dependencies -x test)
echo "✅ Backend dependencies downloaded."
