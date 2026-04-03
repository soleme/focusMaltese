📜 Project: Focus Maltese (집중해 말티즈) 🐶

귀여운 말티즈 요정과 함께 집중 시간을 관리하고, 보상을 통해 강아지를 성장시키는 Flutter 기반 모바일 앱 기획서입니다.

1. Core Concept (핵심 컨셉)

캐릭터: 하얀 말티즈 (집중 요정)

핵심 가치: 힐링 + 동기부여 + 육성 시뮬레이션

주요 기능: 뽀모도로 스타일 타이머, 강아지 상태 변화, 보상 및 아이템 상점

타겟 플랫폼: Mobile (iOS / Android) - Flutter Framework

2. System Design (시스템 설계)

🐾 Dog & Expansion (강아지 데이터 구조)

추후 다른 견종(푸들, 시바견 등)이 추가되어도 코드 수정이 최소화되도록 추상화된 클래스를 사용합니다.

class Dog {
  String breed;           // 견종 (예: 'Maltese')
  String name;            // 강아지 이름
  int level;              // 현재 레벨
  int experience;         // 집중 성공 시 획득하는 경험치
  int treatCount;         // 보유 중인 '개껌' (재화)
  List<String> inventory; // 획득한 꾸미기 아이템 리스트
  String currentStatus;   // 현재 상태 (Idle, Focusing, Success, Fail)
}


⏱️ Timer & Maltese States (타이머 및 강아지 상태)

강아지의 행동과 응원 문구는 타이머의 상태(TimerStatus)와 동기화됩니다.

Idle (대기 모드):

행동: 꼬리를 살랑살랑 흔들며 주인님을 쳐다봄.

멘트: "주인님, 오늘도 집중해봐멍! 꼬리 살랑!"

Focusing (집중 모드):

행동: 바닥에 엎드려서 똘망똘망하게 사용자를 지켜봄.

멘트: "지켜보고 있다멍! 딴짓하면 안 된다멍!"

Success (집중 성공):

행동: 화면을 향해 달려오거나 제자리에서 뱅글뱅글 돌며 기뻐함.

멘트: "천재다멍! 주인님 최고멍! 보상을 주겠다멍!"

Fail (중도 포기):

행동: 시무룩하게 등을 돌리고 앉아 있거나 하품을 함.

멘트: "주인님... 조금 아쉽다멍... 다음엔 꼭 성공하자멍."

3. Reward & Growth (성장 및 보상)

경험치(XP): 집중 성공 시 시간에 비례하여 획득. 레벨업 시 새로운 모션이나 기능 해금.

개껌(Treat): 아이템 구매를 위한 포인트.

상점(Shop): 말티즈에게 입힐 수 있는 리본, 모자, 옷 등을 구매.

확장: 레벨 5 달성 시 새로운 강아지 친구(푸들 등) 입양 권한 부여.

4. Development Roadmap (개발 로드맵)

Phase 1 (MVP): Flutter 기본 프로젝트 설정 및 Timer.periodic 기반 카운트다운 로직 구현.

Phase 2 (Visuals): 말티즈 상태별 이미지/애니메이션 에셋 적용 및 UI 배치.

Phase 4 (Persistence): shared_preferences를 사용해 레벨, 경험치, 아이템 데이터를 기기에 저장.

Phase 4 (Notification): 집중 종료 시 로컬 알림(flutter_local_notifications) 발생 기능 추가.

Phase 5 (Refinement): 상점 기능 추가 및 UI/UX 디테일 고도화.

5. Required Assets (필요 리소스)

Images: 말티즈 애니메이션(GIF 또는 프레임 시퀀스) 4종 (Idle, Focus, Success, Sad).

Sound: 강아지 짖는 소리, 기분 좋은 효과음, 타이머 알림음.

Fonts: 가독성이 좋고 귀여운 느낌의 무료 샌드세리프 폰트.

본 문서는 브레인스토밍 도우미와 함께 작성되었습니다.