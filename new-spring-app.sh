#!/usr/bin/env bash
# Spring Initializr(start.spring.io)로 빈 Spring Boot 프로젝트를 만든다.
# 사용법: bash new-spring-app.sh [이름] [의존성]   (기본: app, web,validation)
# 옵션:   JAVA_VERSION=21  BUILD=gradle-project | maven-project
set -euo pipefail

NAME="${1:-app}"
DEPS="${2:-web,validation}"
JAVA_VERSION="${JAVA_VERSION:-21}"
BUILD="${BUILD:-gradle-project}"
PKG="com.example.$(echo "$NAME" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9')"

if [ -e "$NAME" ]; then echo "[error] ./$NAME 이 이미 있음"; exit 1; fi

curl -fsSL https://start.spring.io/starter.zip \
  -d type="$BUILD" -d language=java -d javaVersion="$JAVA_VERSION" \
  -d groupId=com.example -d artifactId="$NAME" -d name="$NAME" \
  -d packageName="$PKG" -d dependencies="$DEPS" \
  -o "$NAME.zip"

mkdir "$NAME"
if command -v unzip >/dev/null 2>&1; then
  unzip -q "$NAME.zip" -d "$NAME"
elif command -v jar >/dev/null 2>&1; then
  (cd "$NAME" && jar xf "../$NAME.zip")
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e "$NAME.zip" "$NAME"
else
  echo "[error] unzip, jar, python3 중 하나가 필요함"; exit 1
fi
rm -f "$NAME.zip"
chmod +x "$NAME/gradlew" "$NAME/mvnw" 2>/dev/null || true

# 포트 미리보기에서 열리도록 모든 주소에 바인딩
printf '\nserver.address=0.0.0.0\nserver.port=8080\n' >> "$NAME/src/main/resources/application.properties"

echo "./$NAME 생성 (Java $JAVA_VERSION, $BUILD, 의존성: $DEPS)"
if [ "$BUILD" = "maven-project" ]; then
  echo "실행: cd $NAME && ./mvnw spring-boot:run"
else
  echo "실행: cd $NAME && ./gradlew bootRun"
fi
