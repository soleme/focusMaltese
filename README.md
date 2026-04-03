# Focus Maltese

집중해 말티즈는 말티즈 요정과 함께 집중 시간을 관리하는 Flutter 기반 모바일 앱입니다.  
현재 저장소에는 iOS 시뮬레이터에서 실행 가능한 MVP가 구현되어 있습니다.

## 현재 구현 범위
- 25분 / 50분 집중 프리셋
- 집중 시작, 일시정지, 재개, 실패, 성공 흐름
- XP / 개껌 보상과 레벨업 반영
- 로컬 저장 복원
- 최근 세션 기록, 주간 집중 통계, 리듬 통계
- 설정 탭
  - 사운드
  - 진동
  - 집중 종료 알림
  - 진행 데이터 초기화
- iOS 앱 아이콘, 런치 스크린, 상태별 말티즈 이미지 반영

## 개발 환경
- Flutter: `FVM` 기준
- 기본 타겟: iOS Simulator
- 주요 명령:
  - `fvm flutter pub get`
  - `fvm flutter run`
  - `fvm flutter analyze`
  - `fvm flutter test`

## 주요 문서
- [TASK.md](/Users/leo_park/coding/codex01/TASK.md): 현재 결정 사항과 진행 로그
- [DESIGN.md](/Users/leo_park/coding/codex01/DESIGN.md): UI/비주얼 가이드
- [DEV.md](/Users/leo_park/coding/codex01/DEV.md): 개발 환경 기준
- [AGENTS.md](/Users/leo_park/coding/codex01/AGENTS.md): 기여 가이드
- `READEME.md`: 초기 기획 초안 문서

## 현재 구조
- `lib/`: 앱 코드
- `test/`: 위젯/로직 테스트
- `assets/`: 샘플 이미지와 말티즈 상태 에셋
- `ios/`: iOS 프로젝트 설정

## 검증 상태
- `fvm flutter analyze` 통과
- `fvm flutter test` 통과

## 다음 작업 후보
- 상점 / 꾸미기 아이템
- 다른 견종 확장
- 실제 알림 UX 고도화
- Android 환경 검증
