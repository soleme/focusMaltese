# Focus Maltese MVP Task

## Summary
첫 개발 사이클은 Flutter 기반 모바일 앱의 집중 타이머 MVP에 집중한다.
첫 버전의 구현 범위는 말티즈 상태 변화, 집중 완료 보상 적립, 기본 레벨 성장까지로 제한한다.
상점, 장착, 견종 확장, 로컬 알림은 후속 단계로 미룬다.

## Product Direction
- 플랫폼은 iOS / Android 공통 Flutter 앱으로 개발한다.
- 앱의 핵심 가치는 힐링, 동기부여, 육성 시뮬레이션이다.
- 첫 버전은 단일 화면 MVP로 시작한다.
- 실제 말티즈 에셋이 없으므로 상태별 플레이스홀더 UI로 먼저 개발한다.

## MVP Scope
- 집중 시작 / 중지 / 완료가 가능한 타이머 구현
- 말티즈 상태 전환 구현
  - idle
  - focusing
  - success
  - fail
- 상태별 문구와 시각적 구분 반영
- 집중 성공 시 XP와 개껌 적립
- XP 누적에 따른 레벨업 처리
- 현재 레벨, XP, 개껌 보유량 표시

## Out of Scope
- 상점 기능
- 아이템 장착
- 다른 견종 해금
- 로컬 알림
- 실제 애니메이션 에셋 연동
- 복잡한 상태관리 라이브러리 도입

## Architecture
- Flutter 기본 상태 관리로 시작한다.
- `StatefulWidget + 서비스 클래스 분리` 구조를 사용한다.
- 초기 구조는 가볍게 유지한다.
- 복잡도가 커지면 이후 Riverpod 또는 Bloc 도입을 재검토한다.

## Domain Model
### Dog
- breed
- name
- level
- experience
- treatCount
- inventory
- currentStatus

### FocusSession
- targetDuration
- remainingDuration
- status
- startedAt
- endedAt

### RewardPolicy
- 성공 시 XP 계산
- 성공 시 개껌 계산
- 레벨업 기준 계산

## Timer State Machine
- `idle -> focusing -> success`
- `idle -> focusing -> fail`
- `success`, `fail` 상태는 결과 표시 후 다시 `idle`로 복귀

## UI Plan
- 상단: 말티즈 캐릭터 영역
- 중앙: 남은 시간, 현재 상태 문구, 시작/중지 버튼
- 하단: 레벨, XP, 개껌 보유량 표시

## Implementation Notes
- `Timer.periodic` 기반 카운트다운으로 시작한다.
- 타이머 계산 로직과 화면 표시 로직은 분리한다.
- 상태별 문구와 보상 규칙은 상수로 관리한다.
- 보상 계산식은 단순한 기본값으로 시작한다.
  - 예시: 1분당 XP 10, 개껌 1
- 실패는 사용자가 중도 종료한 경우로 정의한다.
- 백그라운드 전환 정책은 초기 버전에서 단순 처리한다.

## Persistence Plan
- 첫 구현은 메모리 상태만으로도 시작 가능하다.
- 이후 `shared_preferences`로 레벨, XP, 개껌, 현재 상태를 저장한다.

## Test Cases
- 타이머 시작 시 `idle`에서 `focusing`으로 바뀌는지 확인
- 타이머 완료 시 `success`로 전환되는지 확인
- 완료 시 보상이 한 번만 적립되는지 확인
- 중도 종료 시 `fail`로 전환되고 보상이 지급되지 않는지 확인
- 성공 후 다시 새 세션을 시작할 수 있는지 확인
- XP 누적으로 레벨업이 정상 반영되는지 확인
- 저장 기능 도입 후 앱 재실행 시 데이터가 유지되는지 확인

## Cleanup
- `READEME.md` 파일명 오타를 정리할지 검토
- 로드맵의 `Phase 4` 중복 표기를 정리

## Conversation Summary
### Product Decisions
- 첫 개발 사이클은 Flutter 기반 모바일 앱의 집중 타이머 MVP에 집중한다.
- 첫 버전은 `타이머 MVP + 기본 보상 적립`까지를 실제 구현 범위로 둔다.
- 상점, 장착, 견종 확장, 로컬 알림은 후속 단계로 미룬다.
- 실제 말티즈 에셋이 없으므로 상태별 플레이스홀더 UI로 먼저 개발한다.

### UI / Design Decisions
- 디자인 기준 이미지는 `assets/sample1.png`이다.
- 전체 톤은 따뜻하고 부드러운 힐링형 생산성 앱으로 유지한다.
- 메인 화면은 큰 카드형 단일 화면 구조로 설계한다.
- 상태별 색 역할을 분리한다.
  - idle: 세이지 그린
  - focusing: 하늘색/민트 블루
  - success: 골드/허니 옐로우
  - fail: 톤다운된 코랄/로즈
- 성공 상태에서만 보상 카드와 장식을 강하게 강조한다.

### Development Environment Decisions
- 개발 환경은 `docker-compose` 없이 macOS 로컬 네이티브 환경으로 구성한다.
- Flutter SDK는 전역 설치 기준이 아니라 `FVM`으로 프로젝트 단위 버전 고정을 사용한다.
- 초기 실행 환경은 `Xcode + iPhone Simulator` 기준이다.
- 기본 품질 게이트는 `format`, `analyze`, `test`로 단순하게 유지한다.
- 초기 CI는 GitHub Actions 기준으로 `flutter analyze`, `flutter test`만 검사한다.

### Data / Infrastructure Decisions
- MVP에서는 서버형 DB를 사용하지 않는다.
- 데이터는 단일 사용자, 단일 기기 기준 로컬 저장만 지원한다.
- 저장 대상은 레벨, XP, 개껌, 인벤토리, 마지막 상태 정도로 제한한다.
- 초기 persistence는 `shared_preferences` 또는 동급의 단순 로컬 저장으로 시작한다.
- 로그인, 계정 복구, 기기 간 동기화, 분석 도구, 원격 설정, 관리자 기능은 초기 범위에서 제외한다.

### Additional Product Decisions
- 초기 세션 시간은 `25분 집중`, `50분 몰입` 두 가지 프리셋만 제공한다.
- 앱이 백그라운드로 가면 진행 중 세션은 실패 처리하지 않고 `일시정지` 상태로 전환한다.
- 초기 앱 UI 문구는 다국어 없이 `한국어만` 사용한다.

### Implementation Progress
- Flutter 프로젝트를 저장소 루트에 생성했다.
- `FVM` 기반 Flutter SDK 연결을 완료했다.
- 기본 생성 예제 코드를 제거하고 `집중해 말티즈` MVP 화면으로 교체했다.
- 현재 구현된 기능:
  - 단일 화면 카드형 홈 UI
  - `25분 집중`, `50분 몰입` 프리셋 선택
  - 타이머 시작, 진행, 중도 종료
  - 백그라운드 진입 시 자동 일시정지
  - 집중 성공 시 XP/개껌 보상 계산
  - 레벨업 반영
  - `shared_preferences` 기반 로컬 저장 및 복원
- 현재 검증 상태:
  - `flutter analyze` 통과
  - `flutter test` 통과
  - iPhone Simulator 실행 및 앱 설치 확인 완료
  - 최신 빌드 기준 홈 화면 캡처 확인 완료

### Simulator Progress
- Xcode license 승인과 `runFirstLaunch` 초기화를 완료했다.
- iOS 26.4 Simulator platform 다운로드 및 설치를 완료했다.
- `iPhone 17 Pro` 시뮬레이터에서 앱 설치와 실행을 확인했다.

### UI Polish Progress
- 앱 재진입 시 `fail/success` 상태를 그대로 복원하지 않고 `idle` 상태로 정리하도록 조정했다.
- 상단 헤더에서 이름과 견종 표기를 분리해 가독성을 높였다.
- 상태 안내 문구를 별도 카드로 분리했다.
- XP 진행률 바를 추가해 성장 체감을 보강했다.
- 카드 레이아웃을 상단 정렬 기반으로 조정해 첫 화면 인상을 정리했다.
- 상태 전환 시 일러스트와 액션 패널에 `AnimatedSwitcher` 기반 전환 애니메이션을 추가했다.
- 성공 상태에서 반짝이 장식을 추가해 보상 순간을 더 강조했다.
- 홈 상태에 보조 안내 문구를 추가해 프리셋 선택 의도를 더 분명하게 만들었다.
- 최신 빌드 기준으로 `iPhone 17 Pro / iOS 26.4` 시뮬레이터 화면을 다시 확인했다.

### Native Branding Progress
- iOS `LaunchScreen.storyboard`를 기본 빈 스플래시에서 브랜드 카드형 런치 화면으로 교체했다.
- iOS 앱 표시 이름을 `집중해 말티즈`로 변경했다.
- 최신 빌드를 다시 시뮬레이터에 설치해 반영 가능 상태를 확인했다.
- AppIcon 세트를 기본 Flutter 아이콘에서 발바닥 중심 브랜드 아이콘으로 교체했다.
- 1024 원본 아이콘을 생성하고 iOS 아이콘 크기별 PNG로 모두 리사이즈해 반영했다.

### Reward Balance Progress
- 보상 수치를 초기보다 완화했다.
  - 25분: `120 XP`, `개껌 2개`
  - 50분: `240 XP`, `개껌 4개`
- 레벨업 임계치도 `120 + ((level - 1) * 80)` 기준으로 조정했다.
- 이에 맞춰 테스트 기대값도 갱신했고 다시 통과를 확인했다.

### App Structure Progress
- 하단 탭 기반 `AppShell`을 추가했다.
- 첫 탭은 기존 집중 홈 화면, 두 번째 탭은 `말티즈 상태 / 성장 진행도 / 현재 세션 / 다음 확장 준비`를 보여주는 개요 화면으로 구성했다.
- 홈 화면의 스냅샷을 상위 셸로 전달해 두 번째 탭에서 현재 상태를 읽어 표시하도록 연결했다.
- 탭 전환 동작을 검증하는 테스트를 추가했다.

### Statistics Progress
- 스냅샷에 `completedSessions`, `totalFocusMinutes`, `lastCompletedAt` 필드를 추가했다.
- 집중 성공 시 완료 세션 수와 누적 집중 시간을 저장하도록 연결했다.
- `말티즈` 탭에서 `완료 세션`, `누적 집중`, `마지막 성공 시각`을 볼 수 있도록 개요 화면을 확장했다.
- 최근 성공 세션 5개를 저장하는 `recentRecords`를 추가했다.
- `말티즈` 탭에서 최근 세션별 `집중 시간 / 획득 XP / 개껌 / 완료 시각`을 볼 수 있도록 확장했다.
- 최근 기록을 30개까지 유지하도록 확장했다.
- `오늘 집중`, `최근 7일 집중`, `연속 성공 흐름` 통계를 `말티즈` 탭에 추가했다.
- `평균 세션`, `가장 긴 집중` 지표를 추가해 기록 화면의 정보 밀도를 높였다.
- 최근 세션 카드를 누르면 상세 정보를 보여주는 바텀시트 모달을 추가했다.
- 최근 7일 흐름을 작은 바 차트로 시각화해 기록 탭의 가독성을 높였다.
- `말티즈` 탭 상단 히어로 카드에 실제 상태별 말티즈 이미지를 노출하도록 바꿨다.

### Settings Progress
- `설정` 탭을 추가했다.
- 설정 화면에서 `사운드`, `진동`, `집중 종료 알림` 토글을 저장할 수 있게 했다.
- `진행 데이터 초기화` 액션을 추가해 레벨/XP/개껌/통계를 초기화할 수 있게 했다.
- 설정 값은 `AppSnapshot.settings`에 포함해 기존 저장 구조 안에서 함께 유지한다.
- `진행 데이터 초기화` 실행 전 확인 다이얼로그를 추가했다.
- `집중 종료 알림` 토글은 실제 `flutter_local_notifications` 권한 요청 및 예약/취소 흐름과 연결했다.
- iOS 알림 권한 상태를 읽어 설정 화면에 `허용됨 / 권한 필요` 상태로 표시하도록 확장했다.
- `사운드`와 `진동` 토글을 실제 피드백 동작과 연결했다.
  - 프리셋 선택
  - 세션 시작 / 일시정지 / 재개
  - 성공 / 실패
  - 보상 수령 / 재시도
  - 시스템 사운드와 햅틱을 상태에 맞게 다르게 사용한다.
- 알림 권한이 없을 때 설정 화면에 별도 안내 카드와 권장 순서를 표시하도록 확장했다.
- 안내 카드에 `iPhone 설정 열기` 액션을 추가했다.
- 설정 탭 상단에 현재 `사운드 / 진동 / 알림 권한` 상태를 바로 읽을 수 있는 요약 칩을 추가했다.

### Asset Structure Progress
- 상태별 말티즈 이미지를 위한 에셋 구조를 추가했다.
- 기대 경로:
  - `assets/maltese/idle.png`
  - `assets/maltese/focusing.png`
  - `assets/maltese/paused.png`
  - `assets/maltese/success.png`
- `assets/maltese/fail.png`
- 실제 이미지가 없을 때는 자동으로 기존 아이콘 플레이스홀더를 사용하도록 fallback을 넣었다.
- 상태별 플레이스홀더 PNG 5종을 실제 파일로 생성했다.
- `pubspec.yaml`에 `assets/maltese/`를 명시적으로 추가해 번들 포함 문제를 해결했다.
- 최신 시뮬레이터 빌드 기준으로 홈 화면에서 실제 PNG가 보이는 것까지 확인했다.
- `sample1.png`를 기반으로 상태별 말티즈 일러스트를 다시 크롭해 더 자연스러운 캐릭터 세트로 교체했다.
- 홈 화면 일러스트 노출 크기도 키워서 캐릭터 존재감이 더 잘 드러나게 조정했다.

### State UI Polish Progress
- 성공 보상 카드를 더 풍부한 정보 구조로 확장했다.
  - 경험치/개껌을 분리된 통계 행으로 표시
  - 레벨업 시 추가 안내 문구 표시
- 실패, 집중 중, 일시정지 상태의 버튼 색과 문구를 각 상태에 맞게 더 분명히 구분했다.
- 타이머 아래 보조 설명을 상태별로 추가해 현재 문맥이 더 잘 드러나게 조정했다.

### Working Rule
- 앞으로 사용자와 나눈 주요 결정 사항은 이 `TASK.md`에 계속 요약해서 누적 기록한다.

### Repo Setup Progress
- 기본 Flutter README를 프로젝트 소개 README로 교체했다.
- 저장소를 `git init`으로 초기화했다.
