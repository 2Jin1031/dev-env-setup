# dev-env-setup

리눅스 터미널에서 Java/Spring 개발 환경을 빠르게 준비하는 스크립트 모음.
sudo 없이 홈 디렉터리에 설치한다.

## 1. JDK 설치

```bash
git clone https://github.com/2Jin1031/dev-env-setup.git
cd dev-env-setup
bash setup-jdk.sh          # 기본 21. 다른 버전은 bash setup-jdk.sh 25
source ~/.jdk-env
java -version
```

java가 이미 있으면 설치를 건너뛴다. 그래도 설치하려면 `FORCE=1 bash setup-jdk.sh`.

## 2. 빈 Spring Boot 프로젝트 만들기

```bash
bash new-spring-app.sh app web,validation
cd app && ./gradlew bootRun
```

- 8080 포트, 0.0.0.0에 바인딩
- Maven으로: `BUILD=maven-project bash new-spring-app.sh app web`
- Java 버전: `JAVA_VERSION=25 bash new-spring-app.sh app web`
- 의존성 이름은 start.spring.io 기준 (예: web, validation, data-jpa, h2, thymeleaf)

## 3. Codex에 Context7 MCP 붙이기

Context7은 라이브러리 최신 문서를 찾아주는 MCP 서버다. Spring Boot, JUnit 같은 라이브러리의 버전에 맞는 문서를 Codex가 직접 찾아보게 한다.

```bash
bash setup-mcp.sh          # npx 있으면 로컬 실행, 없으면 원격 주소
codex mcp list             # context7이 보이면 성공
```

- `~/.codex/config.toml`에 `[mcp_servers.context7]` 블록을 추가한다. 기존 파일은 `config.toml.bak.*`로 백업한다.
- 이미 있으면 건너뛴다.
- 방식 고르기: `MODE=url bash setup-mcp.sh` (원격 주소) 또는 `MODE=npx bash setup-mcp.sh`
- Codex를 켜 둔 상태였다면 정상 종료 후 다시 켜고, Codex 안에서 `/mcp`로 확인
- 한쪽 방식이 목록에 안 뜨면 블록을 지우고 다른 방식으로 다시 실행
- 프롬프트에 `use context7`을 붙이면 문서를 찾아본다
- API 키는 쓰지 않는다 (무료 한도)

## 받아오는 곳

| 무엇 | 어디서 |
|---|---|
| JDK | Eclipse Temurin (api.adoptium.net → github.com/adoptium 릴리스) |
| 프로젝트 뼈대 | Spring Initializr (start.spring.io) |
| 빌드 도구 | Gradle wrapper (services.gradle.org) 또는 Maven wrapper |
| 라이브러리 | Maven Central |
| Context7 MCP | npm `@upstash/context7-mcp` 또는 mcp.context7.com |

첫 빌드 때 Gradle과 라이브러리를 내려받느라 시간이 걸린다.
