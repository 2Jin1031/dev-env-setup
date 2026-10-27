#!/usr/bin/env bash
# Eclipse Temurin JDK를 sudo 없이 $HOME/.local 아래에 설치한다.
# 사용법: bash setup-jdk.sh [버전]   (기본 21)
#         설치 뒤 현재 셸에서: source ~/.jdk-env
set -euo pipefail

VERSION="${1:-21}"
DEST="$HOME/.local/jdk-$VERSION"
ENV_FILE="$HOME/.jdk-env"

if command -v java >/dev/null 2>&1 && [ "${FORCE:-0}" != "1" ]; then
  echo "[skip] java가 이미 있음: $(java -version 2>&1 | head -n 1)"
  echo "       그래도 설치하려면 FORCE=1 bash setup-jdk.sh $VERSION"
  exit 0
fi

case "$(uname -m)" in
  x86_64|amd64) ARCH=x64 ;;
  aarch64|arm64) ARCH=aarch64 ;;
  *) echo "[error] 지원하지 않는 CPU: $(uname -m)"; exit 1 ;;
esac

URL="https://api.adoptium.net/v3/binary/latest/${VERSION}/ga/linux/${ARCH}/jdk/hotspot/normal/eclipse"
TMP="$(mktemp -d)"
START=$(date +%s)

echo "[1/3] Temurin JDK $VERSION ($ARCH) 다운로드"
if command -v curl >/dev/null 2>&1; then
  curl -fL --retry 3 -o "$TMP/jdk.tar.gz" "$URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TMP/jdk.tar.gz" "$URL"
else
  echo "[error] curl이나 wget이 필요함"; exit 1
fi

echo "[2/3] $DEST 에 압축 해제"
rm -rf "$DEST"
mkdir -p "$DEST"
tar -xzf "$TMP/jdk.tar.gz" -C "$DEST" --strip-components=1
rm -rf "$TMP"

cat > "$ENV_FILE" <<EOF
export JAVA_HOME="$DEST"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
LINE="[ -f \"$ENV_FILE\" ] && . \"$ENV_FILE\""
grep -qxF "$LINE" "$HOME/.bashrc" 2>/dev/null || echo "$LINE" >> "$HOME/.bashrc"

END=$(date +%s)
echo "[3/3] 완료 ($((END - START))초)"
"$DEST/bin/java" -version
echo
echo "현재 셸에 적용: source $ENV_FILE"
