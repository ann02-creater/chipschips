# chipschips

## 프로젝트 개요
이 저장소는 Verilog 기반 디지털 회로 설계를 위한 템플릿입니다. VS Code에서 코딩 후 Vivado에서 시뮬레이션을 실행하도록 구성되어 있습니다.

## 디렉토리 설명
- `src/`: 주요 Verilog 소스코드
- `sim/`: 테스트벤치와 시뮬레이션 관련 파일
- `doc/`: 결과 파형 스크린샷 또는 pdf 보고서

## 사용 방법
1. 코드는 VS Code에서 작성합니다.
2. 팀원은 Vivado에서 `.v` 파일을 import하여 실행합니다.
3. 결과물은 `doc/`에 저장해 공유합니다.

# 1 Stop Watch(start, stop, reset 기능포함)

## 📁 Files

🔧 **핵심 모듈들**

1. **clock_divider.v** - 클럭 분주기
   - 100MHz → 1ms (스톱워치용)
   - 100MHz → 8kHz (디스플레이 주사용)

2. **button_debouncer.v** - 8비트 시프트 레지스터 디바운서
   - 8ms 안정화 시간
   - 노이즈 제거 및 edge detection

3. **stopwatch_counter.v** - 스톱워치 핵심 로직
   - MM:SS.CC 형식 시간 계산
   - Start/Stop/Reset 제어

4. **seven_segment_display.v** - 7세그먼트 컨트롤러
   - 8자리 시분할 주사
   - BCD 디코딩

🔗 **통합 모듈**

5. **nexys_a7_stopwatch_top.v** - 최상위 통합 모듈
   - 모든 서브모듈 연결
   - NEXYS A7 핀 매핑

🧪 **테스트**

6. **nexys_a7_stopwatch_tb.v** - 종합 테스트벤치
   - 각 모듈별 개별 테스트
   - 통합 시나리오 테스트

💡 **주요 특징:**

- **모듈식 설계**: 각 기능별로 독립적인 모듈
- **8비트 시프트 레지스터**: 효율적인 디바운싱
- **정확한 타이밍**: 1ms 단위 정밀 측정

## 🚀 How to Simulate
```bash
