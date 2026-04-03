# Repository Guidelines

## 프로젝트 구조 및 모듈 구성
이 저장소는 현재 기획 문서와 구현 코드가 함께 있는 단계입니다. 루트에는 아래 문서가 있습니다.
- `CONCEPT.md`: 초기 프로젝트 컨셉과 로드맵
- `TASK.md`: MVP 범위, 아키텍처 메모, 테스트 체크리스트
- `DESIGN.md`: `assets/sample1.png` 기준의 UI 디자인 가이드
- `assets/`: 참고 이미지와 향후 앱 에셋 저장 위치

Flutter 앱을 생성한 뒤에는 소스 코드는 `lib/`, 테스트는 `test/`, 정적 리소스는 `assets/`에 둡니다. 구조는 `lib/features/timer/`, `lib/features/pet/`, `lib/shared/`처럼 기능 단위로 작게 나누는 방식을 권장합니다.

## 빌드, 테스트, 개발 명령어
아직 Flutter 프로젝트는 생성되지 않았습니다. 생성 후에는 저장소 루트에서 아래 명령어를 사용합니다.
- `flutter pub get`: 의존성 설치
- `flutter run`: 시뮬레이터 또는 기기에서 앱 실행
- `flutter test`: 단위 테스트와 위젯 테스트 실행
- `flutter analyze`: 정적 분석 실행
- `dart format .`: Dart 코드 포맷 적용

도구가 생성한 파일이 아니라면 생성물은 직접 수정하지 않습니다.

## 코딩 스타일 및 네이밍 규칙
Dart 코드는 2칸 들여쓰기를 사용합니다. 네이밍은 Flutter 기본 규칙을 따릅니다.
- 파일명: `snake_case.dart`
- 클래스/위젯: `PascalCase`
- 메서드/변수/필드: `camelCase`

위젯은 작고 명확하게 유지합니다. `TASK.md` 기준에 맞춰 초기에는 `StatefulWidget + 서비스 클래스 분리` 구조를 우선 사용합니다. 재사용 UI는 `PetIllustrationCard`, `FocusTimerDisplay`처럼 역할이 드러나는 이름으로 분리합니다.

## 테스트 가이드
테스트는 Flutter 기본 `flutter_test` 패키지를 사용합니다. `test/` 구조는 `lib/` 구조를 따라가고, 파일명은 `timer_service_test.dart`처럼 `_test.dart`로 끝나야 합니다.

`TASK.md`에 정의된 MVP 흐름을 우선 검증합니다. 타이머 시작, 성공, 실패, 보상 지급, 레벨업 동작은 기본 테스트 범위입니다. 첫 화면 구현 후에는 상태별 UI를 검증하는 위젯 테스트도 추가합니다.

## 커밋 및 풀 리퀘스트 규칙
아직 Git 히스토리가 없으므로 처음부터 간단한 규칙을 사용합니다.
- 커밋 형식: `type: 짧은 설명`
  예시: `feat: add focus timer state model`

권장 타입은 `feat`, `fix`, `docs`, `refactor`, `test`, `chore`입니다.

PR에는 아래 내용을 포함합니다.
- 사용자 관점 변경 요약
- 연결된 작업 또는 이슈 링크가 있다면 함께 첨부
- UI 변경 시 스크린샷 포함
- 실행한 테스트 기록 (`flutter test`, `flutter analyze`)

## 에이전트 메모
코드 구현 전에는 항상 `TASK.md`와 `DESIGN.md`를 기준으로 변경 방향을 맞춥니다. `CONCEPT.md`와 범위 또는 디자인 결정이 충돌하면 현재 기준 문서는 `TASK.md`와 `DESIGN.md`로 간주합니다.
