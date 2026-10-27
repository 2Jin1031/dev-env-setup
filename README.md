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

## 받아오는 곳

| 무엇 | 어디서 |
|---|---|
| JDK | Eclipse Temurin (api.adoptium.net → github.com/adoptium 릴리스) |
| 프로젝트 뼈대 | Spring Initializr (start.spring.io) |
| 빌드 도구 | Gradle wrapper (services.gradle.org) 또는 Maven wrapper |
| 라이브러리 | Maven Central |

첫 빌드 때 Gradle과 라이브러리를 내려받느라 시간이 걸린다.
