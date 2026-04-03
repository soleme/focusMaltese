# Focus Maltese Development Environment Plan

## Summary
Focus Maltese 프로젝트는 `docker-compose` 없이 macOS 로컬 네이티브 환경에서 개발한다.
전역 Flutter 설치 의존을 줄이기 위해 `FVM`으로 Flutter SDK 버전을 프로젝트 단위로 고정한다.
초기 개발 타겟은 iOS 우선이며, 실행 환경은 `Xcode + iPhone Simulator`를 기준으로 한다.

## Goals
- iOS MVP를 실제 시뮬레이터에서 빠르게 확인할 수 있어야 한다.
- 팀원과 CI가 같은 Flutter 버전을 사용해야 한다.
- 환경 차이로 인한 빌드 및 실행 문제를 최소화해야 한다.
- 초기 품질 검사는 `format`, `analyze`, `test` 수준으로 단순하게 유지한다.

## Required Local Tools
- Homebrew
- Git
- FVM
- Xcode
- Xcode Command Line Tools
- CocoaPods

## SDK Strategy
- 전역 `flutter` 대신 `fvm flutter`를 표준 명령으로 사용한다.
- Flutter 버전은 프로젝트에 고정한다.
- 로컬 개발과 CI 모두 같은 Flutter 버전을 사용한다.

## Project Structure
Flutter 프로젝트 생성 후 아래 구조를 기본으로 사용한다.

- `lib/`
- `test/`
- `assets/`
- `lib/features/timer/`
- `lib/features/pet/`
- `lib/shared/`

## Standard Commands
- `fvm install`
- `fvm flutter doctor`
- `fvm flutter pub get`
- `fvm flutter run`
- `fvm flutter test`
- `fvm flutter analyze`
- `dart format .`

## Local Development Workflow
1. FVM으로 Flutter 버전을 설치한다.
2. `fvm flutter doctor`로 로컬 환경을 점검한다.
3. Flutter 프로젝트를 생성하거나 기존 프로젝트 의존성을 설치한다.
4. `fvm flutter run`으로 iPhone Simulator에서 실행한다.
5. 개발 중에는 `dart format .`, `fvm flutter analyze`, `fvm flutter test`를 반복 실행한다.

## iOS Policy
- 초기 기본 타겟은 iOS이다.
- 시뮬레이터 실행과 UI 확인은 Xcode 환경을 기준으로 한다.
- iOS 아카이브, 코드 서명, TestFlight 배포는 초기 범위에서 제외한다.

## CI Plan
- Git 저장소 초기화 후 GitHub Actions를 사용한다.
- PR 또는 push 시 아래 항목을 검사한다.
  - `fvm flutter analyze`
  - `fvm flutter test`
- 초기 CI에서는 배포 자동화나 iOS 빌드 아카이브는 포함하지 않는다.

## Out of Scope
- Docker 기반 개발 환경
- Android Studio / Android SDK 초기 설정
- 웹 배포 환경
- 배포 서명 및 스토어 업로드 자동화

## Assumptions
- 개발 머신은 macOS Apple Silicon 기준이다.
- 팀은 Flutter를 전역 설치 방식이 아닌 FVM 기준으로 사용한다.
- Android 환경은 MVP가 안정화된 뒤 추가한다.
- 초기 기획 문서는 `CONCEPT.md`로 유지하고, 사용자용 소개 문서는 `README.md`를 기준으로 관리한다.
