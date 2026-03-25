<div align="center">

# 🥃 Oakey

### *위스키 라벨을 찍으면, 위스키를 알려드립니다*

> **OCR + 유사 문자열 검색 + 풍미 분석**을 결합한 위스키 탐색·추천 서비스

<br/>

[![Backend](https://img.shields.io/badge/Backend-Spring_Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://github.com/tjoeun-project-02/backend)
[![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://github.com/tjoeun-project-02/frontend)
[![OCR](https://img.shields.io/badge/OCR-Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://github.com/tjoeun-project-02/backend)
[![DB](https://img.shields.io/badge/DB-Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://github.com/tjoeun-project-02/backend)
[![Deploy](https://img.shields.io/badge/Deploy-AWS-232F3E?style=for-the-badge&logo=amazonwebservices&logoColor=white)](https://github.com/tjoeun-project-02/backend)

</div>

---

## 📌 프로젝트 소개

위스키는 이름이 영어고 라벨 폰트도 특이해서, **초보자가 제품명을 정확히 몰라 검색에 실패하는 경우**가 많습니다.

Oakey는 이 문제를 해결하기 위해 만든 서비스입니다.

> 라벨 사진 한 장 → OCR 텍스트 추출 → 유사 문자열 매칭 → 위스키 정보 + 풍미 + 리뷰 제공

정확한 이름을 몰라도, 라벨 이미지만 있으면 위스키를 찾을 수 있습니다.

---

## 🗂️ 레포지토리 구성

| 레포 | 내용 |
|------|------|
| [`backend`](https://github.com/tjoeun-project-02/backend) | Spring Boot API 서버 (`/sts`) + Python OCR 서비스 (`/python`) |
| [`frontend`](https://github.com/tjoeun-project-02/frontend) | Flutter 앱 (Android / iOS) |

---

## ✨ 핵심 기능

### 📷 라벨 OCR 검색
위스키 라벨을 촬영하면 Python OCR 서비스가 텍스트를 추출합니다.
OCR 결과가 완벽하지 않은 상황을 고려해, **정확 일치가 아닌 유사 문자열 기반으로 후보를 탐색**합니다.

```
사용자 촬영 → OCR 추출 (e.g. "springbanr")
         → DB 유사도 검색 (Springbank 매칭)
         → 상위 후보 제공
```

### 🥃 위스키 상세 정보
외부 데이터(whiskybase 크롤링 + 오픈 CSV)를 수집·정제한 **약 300~500개의 위스키 데이터**를 제공합니다.

| 정보 항목 | 내용 |
|----------|------|
| 기본 정보 | 이름, 증류소, 카테고리, 숙성 연수, 도수(ABV), 가격, 평점 |
| 리뷰 | Nose / Taste / Finish / Overall 구조화 리뷰 |
| 풍미 | Fruity · Sweet · Peaty · Spicy · Woody · Malty (비율 합 100) |

### 🎯 풍미 기반 추천
설문을 통해 사용자 취향을 파악하고, 풍미 벡터를 기반으로 위스키를 추천합니다.

```
예시) Springbank 12y
  ├── Fruity  40
  ├── Sweet   35
  └── Woody   25
```

### 🔐 소셜 로그인 / 인증
Spring Security + JWT (Access / Refresh Token) + Kakao OAuth2 로그인을 적용했습니다.

---

## 🏗️ 아키텍처

```
┌──────────────────────────────────────────────────────┐
│                   Flutter App (Android/iOS)           │
└───────────────────────┬──────────────────────────────┘
                        │ REST API
          ┌─────────────▼──────────────┐
          │   Spring Boot (EC2)         │
          │   - JWT 인증                │
          │   - 위스키 CRUD             │
          │   - 검색 / 추천 API         │
          └──────┬──────────┬──────────┘
                 │          │
    ┌────────────▼──┐  ┌────▼──────────────────┐
    │  Oracle DB    │  │  Python OCR Service    │
    │  (RDS)        │  │  Docker → ECR → Lambda │
    └───────────────┘  └────────────────────────┘

  정적 파일 → S3
```

---

## 🛠️ 기술 스택

### Backend

![Java](https://img.shields.io/badge/Java-007396?style=flat-square&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-6DB33F?style=flat-square&logo=springboot&logoColor=white)
![Spring Security](https://img.shields.io/badge/Spring_Security-6DB33F?style=flat-square&logo=springsecurity&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-000000?style=flat-square&logo=jsonwebtokens&logoColor=white)
![Oracle](https://img.shields.io/badge/Oracle-F80000?style=flat-square&logo=oracle&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)

### Frontend

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)

### Infra / Deploy

![AWS EC2](https://img.shields.io/badge/EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)
![AWS RDS](https://img.shields.io/badge/RDS-527FFF?style=flat-square&logo=amazonrds&logoColor=white)
![AWS S3](https://img.shields.io/badge/S3-569A31?style=flat-square&logo=amazons3&logoColor=white)
![AWS ECR](https://img.shields.io/badge/ECR-FF9900?style=flat-square&logo=amazonwebservices&logoColor=white)
![AWS Lambda](https://img.shields.io/badge/Lambda-FF9900?style=flat-square&logo=awslambda&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)

---

## 📊 DB 설계

```
tb_user        사용자 계정 (이메일, 닉네임, 권한, 생성일시)
tb_social      소셜 로그인 연동 (provider, provider_id, user_id)
tb_whisky      위스키 마스터 (이름, 증류소, 카테고리, 도수, 평점, 이미지 ...)
tb_review      구조화 리뷰 (nose / taste / finish / overall)
tb_comment     사용자 댓글
tb_flavor      풍미 키워드 (대표 3개, 비율 합 100)
```

---

## 🚀 배포 구조

| 서비스 | 배포 방식 |
|--------|-----------|
| Spring Boot API | JAR 빌드 → **EC2** 실행 |
| Python OCR | Docker 이미지 → **ECR** → **Lambda** 컨테이너 이미지 배포 |
| 정적 파일 | **S3** 업로드 |
| DB | **RDS** (Oracle) |

> Lambda는 컨테이너 이미지 방식으로 배포해, 의존성이 많은 Python OCR 환경을 그대로 패키징했습니다.

---

## 📁 프로젝트 구조

```
backend/
├── sts/               # Spring Boot 메인 서버
│   ├── config/        # Security, JWT, OAuth2 설정
│   ├── controller/    # API 엔드포인트
│   ├── service/       # 비즈니스 로직
│   ├── repository/    # Oracle DB 연동
│   └── entity/        # 도메인 모델 (whisky, user, review, flavor ...)
├── python/            # OCR 서비스 (Docker 이미지 대상)
└── requirements.txt   # Python 의존성

frontend/
├── lib/               # Flutter 앱 소스
│   ├── screens/       # 화면 구성
│   ├── widgets/       # 공통 컴포넌트
│   └── services/      # API 통신
└── assets/            # 이미지, 폰트 등 정적 자원
```

---

## 🔧 트러블슈팅

### 1. OCR 오탈자 대응 — Oracle 유사도 검색

**문제** : OCR 결과가 완벽하지 않아 정확 일치 검색이 실패하는 경우 발생
```
DB    → Springbank
OCR   → springbanr   (오인식)
```

**검토한 해결 방향** : Oracle `UTL_MATCH` 패키지의 `EDIT_DISTANCE` / `JARO_WINKLER_SIMILARITY` 함수 활용

**발생한 이슈** : 일반 계정에서 `UTL_MATCH` 실행 시 권한 부족 오류
```
ORA-01031: insufficient privileges
→ SYS 레벨 GRANT EXECUTE 필요
```

---

### 2. JWT WeakKeyException

**문제** : JWT 시크릿 키 설정 후 서버 기동 시 예외 발생
```
WeakKeyException: Key length too short for HMAC-SHA256
```

**원인** : JWA 스펙상 HMAC-SHA256은 256비트(32자) 이상의 키를 요구하는데, 짧은 문자열을 입력

**해결** : 충분한 길이의 랜덤 키로 변경, Access/Refresh Token 만료 시간 별도 설정으로 분리
```yaml
oakey.jwt.secret: <256비트 이상 랜덤 키>
oakey.jwt.access-exp-seconds: 3600
oakey.jwt.refresh-exp-seconds: 604800
```

---

### 3. Spring Security 빈 초기화 문제

**문제** : `JwtAuthenticationFilter`, `JwtTokenProvider` 등 보안 관련 빈 설정 중 기동 실패
```
UnsatisfiedDependencyException
```

**해결** : 빈 등록 순서 정리 및 Security 설정 분리, 필터 체인 구조 재구성

---

<div align="center">

[![Backend Repo](https://img.shields.io/badge/Backend_Repository-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/tjoeun-project-02/backend)
[![Frontend Repo](https://img.shields.io/badge/Frontend_Repository-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/tjoeun-project-02/frontend)

</div>
