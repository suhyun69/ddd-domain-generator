# 🧱 DDD Domain Generator for Spring Boot

> Hexagonal Architecture + Clean Code 기반의 Spring Boot DDD 도메인 구조를 자동 생성하는 Shell 스크립트 모음입니다.

---

## 📦 개요

이 레포지토리는 다음과 같은 경우에 유용합니다:

- 반복적인 도메인 구조 생성이 번거로운 경우
- 팀원 간 통일된 디렉토리 및 클래스 구조를 유지하고 싶은 경우
- 빠른 프로토타이핑과 설정 파일 자동 생성을 원하는 경우

---

## 🚀 주요 기능

| 스크립트 | 설명 |
|----------|------|
| `init_shell.sh` | 전체 구성 자동 생성 (도메인 포함) |
| `add-dependencies.sh` | `build.gradle`에 필수 의존성 추가 |
| `generate_config.sh` | Spring Security 및 Swagger 설정 파일 생성 |
| `generate_security.sh` | JWT 유틸리티 및 인증 필터 클래스 생성 |
| `generate_global_exception.sh` | 전역 예외 처리 구조 자동 생성 |
| `generate_resources_application.sh` | `application.yml` 및 환경별 설정 생성 |
| `generate_hex_domain.sh` | 일반 도메인 생성기 (입력 이름 기반) |
| `generate_hex_domain_user.sh` | `user` 도메인 구조 생성 |
| `generate_hex_domain_auth.sh` | `auth` 도메인 구조 생성 (로그인 포함) |

---

## 🛠️ 사용 방법

### 1. 클론

```bash
git clone https://github.com/your-name/ddd-domain-generator.git
cd ddd-domain-generator
```

### 2. 전체 구조 생성

```bash
chmod +x init_shell.sh
./init_shell.sh com.latinhouse.backend
```
- 인자값 com.latinhouse.backend은 생성할 Java 패키지 이름입니다.
- 내부적으로 com/latinhouse/backend로 변환되어 src/main/java 하위 디렉토리에 파일이 생성됩니다.

---

## 📂 생성되는 구조 예시
src/main/java/com/latinhouse/backend/  
├── user/  
│ ├── adapter/  
│ ├── application/  
│ ├── domain/  
│ ├── port/  
├── auth/  
│ ├── adapter/  
│ ├── application/  
│ ├── domain/  
│ ├── port/  
├── config/  
├── security/  
├── global/  
│ └── exception/  
src/main/resources/  
├── application.yml  
├── application-dev.yml  
├── application-prod.yml  
└── application-secret.yml

---

## 🔌 자동 추가되는 Gradle 의존성
implementation group: 'org.springdoc', name: 'springdoc-openapi-starter-webmvc-ui', version: '2.2.0'  
implementation 'io.jsonwebtoken:jjwt-api:0.11.5'  
runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'  
runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'
- build.gradle 위치는 기본적으로 ../build.gradle을 기준으로 합니다.

---

## ✅ 요구사항
Java 17 이상  
Gradle 기반 Spring Boot 프로젝트  
프로젝트 루트에서 다음 디렉토리 존재
- src/main/java
- src/main/resources
- build.gradle

---

## 🔧 커스터마이징 방법
새로운 도메인 스크립트를 만들고 싶다면 generate_hex_domain_user.sh 또는 generate_hex_domain.sh를 복사 후 이름만 바꿔주세요.  
generate_hex_domain.sh는 인자로 도메인명을 받아 다양한 도메인 자동 생성에 재사용 가능  
고도화를 원한다면 Hygen, Plop.js, JHipster 등의 코드 생성기로 확장 가능

---

## 📸 실행 예시

```bash
./init_shell.sh com.example.project
```

📁 생성 중: config  
✅ SecurityConfig.java 생성 완료  
📁 생성 중: global.exception  
✅ GlobalExceptionHandler.java 생성 완료  
📁 생성 중: auth 도메인  
✅ Auth 도메인 생성 완료  
...

---

## 📄 라이선스
MIT License
자유롭게 사용/수정 가능하며, 상업적 프로젝트에도 사용 가능합니다.

---

## 🙋 문의 및 기여
Pull Request 및 Issue 언제든지 환영합니다!
필요한 기능 요청, 버그 제보, 개선 아이디어 모두 감사합니다.

---



