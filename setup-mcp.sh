#!/usr/bin/env bash
# Codex CLI에 Context7 MCP(라이브러리 최신 문서 검색)를 붙인다.
# 사용: bash setup-mcp.sh            # npx 있으면 로컬 실행, 없으면 원격 주소
#       MODE=url bash setup-mcp.sh   # 원격 주소로 강제
#       MODE=npx bash setup-mcp.sh   # npx로 강제
# API 키는 쓰지 않는다 (무료 한도로 동작).
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG="$CODEX_HOME/config.toml"
MODE="${MODE:-auto}"

mkdir -p "$CODEX_HOME"
touch "$CONFIG"

if grep -q '^\[mcp_servers\.context7\]' "$CONFIG"; then
  echo "이미 $CONFIG 에 [mcp_servers.context7] 가 있다. 건너뛴다."
  echo "바꾸려면 그 블록을 지우고 다시 실행."
  exit 0
fi

if [ "$MODE" = auto ]; then
  if command -v npx >/dev/null 2>&1; then MODE=npx; else MODE=url; fi
fi

if [ -s "$CONFIG" ]; then
  cp "$CONFIG" "$CONFIG.bak.$(date +%Y%m%d%H%M%S)"
fi

case "$MODE" in
  npx)
    cat >> "$CONFIG" <<'EOF'

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
startup_timeout_sec = 60
EOF
    ;;
  url)
    cat >> "$CONFIG" <<'EOF'

[mcp_servers.context7]
url = "https://mcp.context7.com/mcp"
startup_timeout_sec = 30
EOF
    ;;
  *)
    echo "MODE는 auto, npx, url 중 하나." >&2
    exit 1
    ;;
esac

echo "context7 추가 완료 ($MODE 방식) -> $CONFIG"
if command -v codex >/dev/null 2>&1; then
  codex mcp list || true
fi
echo "Codex를 켜 둔 상태였다면 정상 종료 후 다시 켜고, Codex 안에서 /mcp 로 확인."
